# bind.pp - BIND 9 Configuration
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


$dns_base_dir = "/var/local/puppet/bind"

class nameserver {

	# essential packages
	package { [ bind9, dnsutils ]:
		ensure => present
	}

	# The nameserver should run
	service { bind9:
		ensure => running,
		pattern => named,
	}

	nagios2::service { "check_dns": }

	file {
		# This script can create zone definitions
		"/usr/local/bin/update-zones":
			source => "$fileserver/bin/update-zones",
			mode => 755;
		# storage for the zone- and config files
		$dns_base_dir:
			checksum => mtime,
			ensure => directory, mode => 755;
	}

	# create basic structures for managing domains of a organisation
	# this is separated, because I manage domains for people that should not
	# touch each other
	# Valid values for $ensure are "master" and "slave"
	# $servers is a semicolon (;) separated list of IPs of public DNS servers
	#          for this org (don't forget the closing ;!!)
	# $primary is the IP of the primary DNS server for this org
	define org ($ensure, $servers) { 
		$dns_org_dir = "${dns_base_dir}/${name}"
		$dns_aux_dir = "${dns_org_dir}/aux"
		$dns_config_dir = "${dns_org_dir}/config"
		$dns_zones_dir = "${dns_org_dir}/zones"

		# The directory where all zone files for this org are stored
		file {
			[ $dns_org_dir, $dns_aux_dir, $dns_config_dir, $dns_zones_dir ]:
				ensure => directory, checksum => mtime,
				mode => 644, owner => root, group => root;
			"$dns_config_dir/servers.conf":
				content => "$servers\n",
				mode => 644, owner => root, group => root;
		}

		# create appropriate config snippets
		exec { "${name}_update_zones":
			command => "/usr/local/bin/update-zones ${name}",
			subscribe => [ File["/usr/local/bin/update-zones"],
				File["$dns_config_dir/servers.conf"], File[$dns_zones_dir] ],
			refreshonly => true,
			notify => Service[bind9],
		}

		$dns_config_file = "/etc/bind/named.conf.local"
		file { $dns_config_file:
			require => Package[bind9],
		}
		line { "named_include_${name}":
			file => $dns_config_file,
			line => "include \"${dns_config_dir}/${ensure}.conf\";",
			ensure => present,
			require => File[$dns_config_file],
		}
	}

	# Transfers a zonefile from the master and configures it
	# TODO: implement serial = auto
	define domain($org, $soa_primary, $soa_contact, $serial = 'auto',
		$refresh = 7200, $soa_retry = 3600, $expire = 604800, $minimum = 600,
		$nameservers, $domain_data = 'template'
	) {
		$dns_org_dir = "${dns_base_dir}/${org}"

		$dns_aux_dir = "${dns_org_dir}/aux"
		$header = "${dns_aux_dir}/header.${name}"
		$soa = "${dns_aux_dir}/soa.${name}"
		$ns = "${dns_aux_dir}/ns.${name}"
		$mx = "${dns_aux_dir}/mx.${name}"

		$dns_config_dir = "${dns_org_dir}/config"
		$dns_zones_dir = "${dns_org_dir}/zones"

		File { 
			mode => 0644, owner => root, group => root,
			notify => [ Service[bind9], Exec["${org}_update_zones"] ],
		}
		file {
			$header:
				content => template("zones/header.erb");
			$soa:
				content => template("zones/soa.erb");
			$ns:
				content => template("zones/ns.erb");
			$mx:
				content => template("zones/mx.erb");
		}
		case $domain_data {
			'custom': {
				file { "$dns_zones_dir/$name":
					content => template("zones/$org/$name");
				}
			}
			'template': {
				file { "$dns_zones_dir/$name":
					content => template("zones/$org/default.erb");
				}
			}
		}
	}

	# TODO: nagios2 namespace?
	# use $domain if namevar is needed for disabiguation
	define check_dig2($domain = '', $record_type = 'A', $expected_address = '',
		$target_host = $fqdn)
	{
		$diggit = $domain ? {
			'' => $name,
			default => $domain
		}

		$real_name = "check_dig2_${diggit}_${record_type}"
		nagios2::service{ $real_name:
			check_command => "check_dig2!$diggit!$record_type!$expected_address",
			nagios2_host_name => $target_host,
		}
		# Deep hack. This should only be don fpr the edv-bus org
		case $edv_bus_ns {
			'master': {
				nagios2::service{ "check_dig2_${diggit}_${record_type}_ns1":
					check_command => "check_dig2!$diggit!$record_type!$expected_address",
					nagios2_host_name => "ns1.uni-ak.ac.at",
				}
			}
		}
				
	}

}


# Set $edv_bus_ns to 'master' or 'slave'
class edv_bus_nameserver inherits nameserver {

	nameserver::org { "edv-bus":
		ensure => $edv_bus_ns,
		servers => '85.125.165.34; 85.125.165.66; 193.170.188.107;',
	}
	
	case $edv_bus_ns {
		'master': {
			# check our secondary nameserver only once
			nagios2::host{ "ns1.uni-ak.ac.at":
				ip => "ns1.uni-ak.ac.at",
				short_alias => "ns1.AK",
			}
		}
	}

	# EDV-BUS Defaults
	define edv_bus_domain($type = 'web_mail', $soa_primary = 'foo.edv-bus.at.', $soa_contact = 'hostmaster.edv-bus.at.',
		$serial = '2007040501', $refresh = 7200, $soa_retry = 3600, $expire =
		604800, $minimum = 600, $nameservers = [ 'foo.edv-bus.at.',
		'bar.edv-bus.at.', 'chip.edv-bus.at.' ], $domain_data = 'template', $expected_www_ip = "83.64.231.72")
	{
		$org = 'edv-bus'
		nameserver::domain { $name:
			org => $org,
			soa_primary => $soa_primary,
			soa_contact => $soa_contact,
			serial => $serial,
			refresh => $refresh,
			soa_retry => $soa_retry,
			expire => $expire,
			minimum => $minimum,
			nameservers => $nameservers,
			domain_data => $domain_data
		}
		# check for every domain that the serial is up to date
		nameserver::check_dig2 {
			"soa_$name":
			domain => $name,
			record_type => "SOA",
			expected_address => $serial,
		}

		# other checks depending on the domain
		case $type {
			'enum': {
				nameserver::check_dig2 {
					"enum_$name":
					domain => $name,
					record_type => "NAPTR",
					expected_address => 'sip',
				}
			}
			'other': {}
			'web_mail':
			{
				nameserver::check_dig2 {
					"webmail.$name":
						record_type => "CNAME",
						expected_address => "www.$name.";
					"www.$name":
						record_type => "A",
						expected_address => $expected_www_ip;
				}
			}
		}
	}

	edv_bus_nameserver::edv_bus_domain {
		['black.co.at', 'edv-bus.at' ]:
			domain_data => custom;
		[ 'mariatreu.at', 'piaristen.at' ]:
			domain_data => custom,
			expected_www_ip => "85.125.165.67";
		['scout-it.at', 'seccom.at', 'zaczek.net', 'fronleichnam.at' ]:
			type => other,
			domain_data => custom;
		['bienenkuss.at', 'cheesy.at', 'eurokey.at',
			'eurokey-sicherheitstechnik.at', 'krumpschmid.at',
			'krumpschmid.eu', 'lischka.org', 'logopaedie-krenn.at',
			'mul-t-lock.at', 'multi-lock.at', 'multilock.at', 'neuro-rehab.at',
			'schweyer.net', 'tabr.org', 'today.co.at', 'u-ser-vice.at'
		]:
			domain_data => template;
		['4.3.1.3.6.0.4.1.3.4.e164.arpa' ] : type => enum, domain_data => custom;
	}

}

