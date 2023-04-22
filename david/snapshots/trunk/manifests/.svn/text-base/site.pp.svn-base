# site.pp - central node configuration
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# Default path
Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

# Default backup
File { backup => server }

# default smarthost
$smarthost = "smtpscanner.edv-bus.at"
$smarthost_port = "25"
$admin_mail = "david@schmitt.edv-bus.at"

# where to fetch files from
$fileserver = "puppet://puppetmaster.black.co.at/files"

# which server collects munin statistics
$munin_host = '192.168.0.3|83.64.231.7[02]'

# default nagios admin
$default_nagios_admin = "staff"
$default_nagios_admin_email = "staff@edv-bus.at"

import "common.pp"
import "classes/*.pp"

node default { }

node puppetmaster, puppettest2 {
	$dv = etch
	$nagios_parent = "ic.black.co.at"
	$nagios_admin  = "david"
	$nagios_admin_email = "david@schmitt.edv-bus.at"
	include dbp_vserver_etch
	include xen_guest
	include puppetmaster
}

node puppettester {
	$dv = etch
	$nagios_parent = "ic.black.co.at"
	include dbp_vserver_etch
	include xen_guest
	include ssmtp

	#apt_source { test: type => 'deb', url => 'http://security.debian.org/', suite => 'sarge/updates', component => 'main', }
	#apt_source { test-src: type => 'deb-src', url => 'http://security.debian.org/', suite => 'sarge/updates', component => 'main contrib', }
}

node backuppc {
	$dv = etch
	$nagios_parent = "ic.black.co.at"
	$apache2_port = 8080
	include backuppc_server
	include dbp_vserver_etch
	include xen_guest
}

# legacy
node diode, chip {
	$dv = "sarge"
	include dbp_sarge 

	include ntp_server
	include logcheck
	include nagios2::target
	include munin::default_client

	# sarge hack: add a compat symlink
	file { "/etc/init.d/ntp": ensure => "/etc/init.d/ntp-server", }
	# fetch various munin scripts
	file {
		"/usr/local/bin/ntp_":
			source => "$fileserver/bin/ntp_",
			mode => 0755, owner => root, group => root,;
		"/usr/local/bin/iostat":
			source => "$fileserver/bin/iostat",
			mode => 0755, owner => root, group => root,
	}
	# hack spamd loosing rights and other misc
	case $hostname {
		'diode' : {
			$nagios_parent = "ic.black.co.at"
			file { "/var/lib/spamd/.spamassassin/bayes_toks":
				owner => spamd, group => nogroup,
			}
			nagios2::service{ "http_80": check_command => "check_http" }

			# needed for svn *grr*
			$apache2_port = 82
			include apache2
			include no_default_apache2_site
			package { "libapache2-svn": ensure => installed, require => Package["apache2"] }
			file { "/etc/apache2/sites-available/svn":
				source => "$fileserver/diode/apache2/svn.conf",
				before => Package["libapache2-svn"],
				require => Package["apache2"],
				notify => Service["apache2"],
			}
			apache2_module { "dav_svn" : ensure => present, require => "libapache2-svn" }
			apache2_site { "svn": ensure => present, require => "libapache2-svn" }
		}
		'chip' : {
			$nagios_parent = "router-mariatreu"
		}
	}
}

node 'www.mariatreu.at', 'mail.mariatreu.at' {
	$dv = sarge
	$nagios_parent = "chip.mariatreu.at"
	include apt_sarge
	munin::vserver_client { $fqdn: port => 4953 }
	include nagios2::target
	include ssh_server
	# hack around missing puppet_base class
	file { "/etc/hosts":
		source => "$fileserver/hosts",
		mode => 0644, owner => root, group => root
	}
	service { puppet: ensure => stopped, pattern => puppetd, }
}

# aka named.edv-bus.at
node 'chip.edv-bus.at' {
	$dv = etch
	$nagios_parent = "chip.mariatreu.at"
	include dbp_vserver_etch
	include nagios2::target
	$edv_bus_ns = 'slave'
	include edv_bus_nameserver
	munin::vserver_client { $fqdn: port => 4954 }
}

node 'mysql5.mariatreu.at' {
	$dv = etch
	$nagios_parent = "chip.mariatreu.at"
	include dbp_vserver_etch
	munin::vserver_client { $fqdn: port => 4951 }
	include mysql_server
	mysqld_param {
		"bind-address": value => "127.2.0.1";
	}
	# testing
	$apache2_port = 81
	$apache2_ssl = enabled
	$apache2_ssl_port = 444
	include apache2
	include phpmyadmin
}

# vserver_hosts normally have no services installed
node services, ic, 'mx.edv-bus.at' {
	$dv = etch
	$nagios_parent = $hostname ? {
		services => "ic.black.co.at",
		ic => "none",
		mx => "ic.black.co.at"
	}
	$ssh_port = $hostname ? {
		services => 22,
		ic => 2200,
		mx => 22
	}
	include vserver_host
	include munin::default_client
	include xen_guest
	include backuppc_client
	include ssmtp
	include ssh_server
}

node munin {
	$dv = etch
	$nagios_parent = "ic.black.co.at"
	include dbp_vserver_etch
	include xen_guest

	include munin::host
}

node ejabberd {
	$dv = etch
	$nagios_parent = "diode.black.co.at"
	include dbp_vserver_etch
	munin::vserver_client { "$fqdn": port => 4957, bindhost => $ipaddress }
}

node rt {
	$dv = etch
	$nagios_parent = "ic.black.co.at"
	include dbp_vserver_etch
	include xen_guest

	package { [ "request-tracker3.6",
			"libdatetime-perl", "xml-core", "rt3.6-apache2", "libmailtools-perl",
			"libhtml-format-perl", "file", "libcompress-zlib-perl",
			"libio-socket-ssl-perl", "libterm-readline-gnu-perl",
			"libterm-readline-perl-perl", "libapache2-mod-fcgid" ]:
		ensure => installed,
	}
	munin::vserver_client { $fqdn: port => 4954 }
}

node smtpscanner {
	$dv = etch
	$nagios_parent = "mx.edv-bus.at"
	include dbp_vserver_etch_no_ssmtp
	include xen_guest

	include exim4_host
	exim4_test { [ "david@black.co.at", "david@schmitt.edv-bus.at"] : }

	include spamassassin

	include admin_mx

	# port forwarded from ic
	munin::vserver_client { "$fqdn": port => 4955, bindhost => $ipaddress }
}

node nagios {
	$dv = etch
	$nagios_parent = "ic.black.co.at"
	include dbp_vserver_etch
	include xen_guest

	$apache2_port = 8081
	include nagios2
	munin::vserver_client { $fqdn: port => 4956, bindhost => 'ic.black.co.at' }

	# A list of various infrastructure to monitor
	nagios2::extra_host {
		"router-heureka":
			parent => "gateway",
			ip => "83.64.231.65";
		"router-mariatreu":
			parent => "router-heureka",
			ip => "85.125.165.65";
		"router-ak":
			parent => "router-heureka",
			ip => "193.170.188.21";
		"router-gudrun":
			parent => "router-heureka",
			ip => "213.47.218.186";
		"www.uni-ak.ac.at":
			parent => "router-ak",
			ip => "193.170.188.104";
	}
}

# The firewall at my parents place. Has the IP of the primary nameserver of all
# our domains.
node fw-schmidg {
	$nagios_parent = "router-heureka"
	$dhcp_subnet = "10.10.7"

	$edv_bus_ns = 'master'
	include edv_bus_nameserver

	include asterisk
	include munin::default_client

	include firewall

	$uplink_speed = 2048
	$downlink_speed = 2048
	include shaper
}

node fw-gudrun {
	$nagios_parent = "router-heureka"
	$dhcp_subnet = "10.0.0"

	include firewall

	$uplink_speed = 4096
	$downlink_speed = 512
	include shaper

	munin::client { $fqdn: bindhost => "62.178.45.213" }
}

node fw-maria, fw-treu {
	$nagios_parent = "router-mariatreu"
	$dhcp_subnet = "192.168.129"

	include firewall
	include munin::default_client

	$edv_bus_ns = 'slave'
	include edv_bus_nameserver
}

class firewall {
	$dv = etch
	include dbp_etch
	include backuppc_client
	include ssmtp
	include ssh_server
	include firewall_class
}

node 'svn-test.edv-bus.at' {
	$dv = etch
	$nagios_parent = "ic.black.co.at"

	include dbp_vserver_etch
	include xen_guest

	package {
		[ "subversion", "rake", "libopenssl-ruby", "openssl", "rails", "libsqlite3-ruby" ]:
			ensure => installed
	}

	file {
		[ "/data" ]:
			ensure => directory,
			require => Package["subversion"],
	}

	svnserve { trunk:
		source => "https://reductivelabs.com/svn/puppet/trunk",
		path => "/data/trunk",
	}

	file {
		"/etc/cron.daily/puppettest":
			content => "#!bin/bash\ncd /data; for i in *; do ( echo \$i; cd \$i; ( cd test; rake test ) ); done\n",
			mode => 0755,
	}

	# needed for transaction tests
	user { root: groups => adm, }

}

node zion {
	package{"munin-node": ensure => absent }
	service{"munin-node": ensure => stopped }
	exec{"apt-get_update": command => "/bin/echo" }
	include ntp_client
	file { "/etc/hosts":
		source => "$fileserver/hosts",
		mode => 0644, owner => root, group => root,
	}
}

