# ssmtp.pp - Basic ssmtp installation
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class ssmtp {
	$seedfile = "/var/cache/local/preseeding/ssmtp.seeds"

	package { ssmtp:
		ensure => installed,
		responsefile => $seedfile,
		require => File[$seedfile],
	}
	file { $seedfile: content => template("etch/ssmtp.seeds"), }

	ssmtp_option {
		"mailhub": ensure => $smarthost;
		"rewriteDomain": ensure => $fqdn;
		"hostname": ensure => $fqdn;
	}

	# This is a real alias file for exim to search for specific
	# destinations, TODO: replace the * by a correct list of senders
	@@file {
		"$admin_domain_dir/$fqdn":
			content => "*: $admin_mail\n\n",
	}

	# make exim4 and ssmtp classes conflict
	package { exim4: ensure => absent, }

	munin::plugin { [ "exim_mailqueue", "exim_mailstats" ]: ensure => absent }
}

# for ssmtp
$admin_domain_dir = "/var/local/puppet/mail/ssmtp_domains"
$admin_host_dir = "/var/local/puppet/mail/ssmtp_hosts"

# default drop dirs for various stuff
file {
	[ $admin_domain_dir, $admin_host_dir ]:
		ensure => directory, mode => 0755, owner => root, group => root, checksum => mtime;
}


define ssmtp_option ($ensure) {
	replace { "ssmtp_option_$name":
		file => "/etc/ssmtp/ssmtp.conf",
		pattern => "^$name=(?!$ensure).*",
		replacement => "$name=$ensure",
	}
}

# designate a host as recipient for admin mails
# This also requires the 140_local_admin_router
# TODO: refactor exim4 configuration to here
class admin_mx {
	file {
		"/etc/mailname":
			content => "$smarthost\n",
			mode => 0644, owner => root, group => root,
			notify => Service[exim4];
		"/etc/exim4/conf.d/main/00_admin_list":
			content => "domainlist admin_domains = dsearch;$admin_domain_dir\nhostlist admin_hosts = net-dsearch;$admin_host_dir\n",
			mode => 0644, owner => root, group => root,
			notify => Service[exim4];
	}

	update_exim4_param {
		dc_relay_domains: ensure => "+admin_domains";
		dc_relay_nets: ensure => "+admin_hosts";
	}

	package { dnsutils: ensure => installed }

	exec { "bash -c 'for i in $admin_domain_dir/*; do if test ! -e $admin_host_dir/\$(dig +short \$(basename \$i) ) ; then touch \$_ ; fi; done'":
		require => Package [ dnsutils ],
		subscribe => File [ $admin_domain_dir ],
		logoutput => true,
	}
	# TODO: restrict collected files here
	File <<||>>
}

