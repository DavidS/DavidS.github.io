# firewall.pp - Things to do on a firewall
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# This includes networking, filtering and services

class dnsmasq {
	package { dnsmasq:
		ensure => installed,
		notify => Service[dnsmasq],
	}
	# TODO: configure per-firewall settings
	file { 
		"/etc/dnsmasq.d":
			ensure => directory,
			mode => 0755, owner => root, group => root;
		"/etc/dnsmasq.d/puppet":
			content => template("dnsmasq.conf"),
			mode => 0644, owner => root, group => root,
			notify => Service[dnsmasq];
	}
	append_if_no_such_line {
		dir_include:
			file => "/etc/dnsmasq.conf",
			line => "conf-dir=/etc/dnsmasq.d",
			require => File["/etc/dnsmasq.conf"],
			notify => Service[dnsmasq],
	}

	file { "/etc/dnsmasq.conf": checksum => md5, require => Package["dnsmasq"] }
	service { dnsmasq:
		ensure => running,
		pattern => "/usr/sbin/dnsmasq",
		subscribe => File["/etc/dnsmasq.conf"],
	}
}

class firewall_class  {

	include dnsmasq

	file { "/etc/sysctl.conf":
		source => "$fileserver/sysctl.conf.firewall",
		mode => 0644, owner => root, group => root,
		notify => Exec[sysctl_update],
	}

	exec { sysctl_update:
		command => "/sbin/sysctl -p",
		refreshonly => true,
	}

	kernel_module {
		"via_rng": ensure => present,
	}

	# TODO remove when propagated
	line { remove_stupidity:
		file => "/etc/modules",
		line => 'via-rng',
		ensure => absent,
	}

	package { "rng-tools":
		ensure => installed,
		require => Exec["/sbin/modprobe via_rng"], # hackalot
	}

	service { "rng-tools":
		ensure => running,
		pattern => rngd,
		require => Package["rng-tools"]
	}

}

# legacy 
class shaper {
	
	include leshaper
	file { 
		"/etc/init.d/lefantshaper": ensure => absent;
		"/etc/default/lefantshaper": ensure => absent;
	}
}
