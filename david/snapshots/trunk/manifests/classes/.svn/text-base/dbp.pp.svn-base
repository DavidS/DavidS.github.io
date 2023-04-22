# dbp.pp - EDV-Beratung&Service Debian Best Practices
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class dbp_base {

	case $dv { '': { err("no debian version set") } }

	include ssh_client
	include default_user
	include nagios2::target

	# richtige reihenfolge wegen dependencies notwendig
	preseeded_package { [ locales, popularity-contest, apt-listchanges, apticron]: }

	# package was renamed
	$dctrl = $dv ? { sarge => grep-dctrl, etch => dctrl-tools }

	package {
		[screen, mmv, deborphan, less, sudo, iproute, $dctrl,
		# for ifconfig, needed by puppet
		net-tools]:
			ensure => installed;
		# has Installed-Size: 20, compared to the 900+ of -i18n
		debconf-english:
			ensure => installed, before => Package[debconf-i18n];
		[ nvi, lpr, pidentd, ppp, pppconfig, pump, pppoe, pppoeconf, nfs-common,
		  nfs-kernel-server, nagios-nrpe-server, dmidecode, laptop-detect,
		  tasksel, tasksel-data, installation-report, debconf-i18n, info,
		  whiptail
		]:
			ensure => absent
	}

	replace { fix_popularity_contest:
		file => "/etc/popularity-contest.conf",
		pattern => '^PARTICIPATE="no"',
		replacement => 'PARTICIPATE="yes"'
	}

	file {
	"$rubysitedir/facter":
		ensure => present, mode => 0755,
		owner => root, group => root,
		source => "$fileserver/facter",
		recurse => true;
	"$rubysitedir/puppet":
		ensure => present, mode => 0755,
		owner => root, group => root,
		source => "$fileserver/puppet",
		recurse => true;
	"/etc/apt/listchanges.conf":
		mode => 0644, owner => root, group => root,
		source => "$fileserver/$dv/apt-listchanges.conf";
	"/etc/profile":
		source => "$fileserver/profile",
		mode => 0644, owner => root, group => root;
	"/etc/bash.bashrc":
		source => "$fileserver/bash.bashrc",
		mode => 0644, owner => root, group => root;
	"/etc/localtime":
		source => "/usr/share/zoneinfo/Europe/Vienna",
		mode => 0644, owner => root, group => root;
	"/etc/timezone":
		content => "Europe/Vienna\n",
		mode => 0644, owner => root, group => root;
	"/etc/default/locale":
		source => "$fileserver/default_locale",
		mode => 0644, owner => root, group => root;
	"/etc/locale.gen":
		source => "$fileserver/locale.gen",
		mode => 0644, owner => root, group => root;
	"/etc/hosts":
		source => "$fileserver/hosts",
		mode => 0644, owner => root, group => root;
	"/usr/local/bin":
		source => "$fileserver/bin/",
		recurse => true;
	"/etc/cron.hourly/puppet":
		content => "#!/bin/bash\ntime nice puppetd --onetime --logdest syslog --verbose\n",
		mode => 0755, owner => root, group => root;
	}

	service { puppet:
		enable => false,
		pattern => puppetd,
	}

	exec { "/etc/init.d/puppet stop":
		refreshonly => true,
		subscribe => Service["puppet"],
	}

	config_file { "/etc/syslog.conf":
		content => "*.* /dev/tty10\n*.* -/var/log/allmessages\n"
	}

	service {
		sysklogd:
			ensure => running,
			pattern => syslogd,
			subscribe => File["/etc/syslog.conf"];
	}

	vim { vim_default: }

	exec { "/usr/sbin/locale-gen":
		refreshonly => true,
		require => Package[locales],
		subscribe => File["/etc/locale.gen"]
	}
}

class dbp_vserver_etch_no_ssmtp inherits dbp_base {

	apt { default_apt:
		clean => always,
	}

	package {
		# These packages are never needed in the context of a VServer
		[ module-init-tools, modutils, dhcp-client, dhcp3-common
		]:
			ensure => absent;
		# One might argue about these, but usually they are not needed
		[ man-db, manpages, iptables, netcat, traceroute, groff-base, perl-doc, wget
		]:
			ensure => absent;

	}

	service { [ "bootlogd", "bootmisc.sh", "checkfs.sh", "checkroot.sh",
			"console-screen.sh", "halt", "hostname.sh",
			"hwclock.sh", "hwclockfirst.sh", "ifupdown",
			"ifupdown-clean", "keymap.sh", "klogd", "makedev",
			"modutils", "mountall.sh", "mountnfs.sh",
			"mountvirtfs", "networking", "procps.sh", "reboot",
			"rmnologin", "single", "stop-bootlogd", "umountfs",
			"umountnfs.sh", "urandom", "umountroot" ]:
		enable => false
	}

	# handle that from outside
	File["/etc/cron.hourly/puppet"] { ensure => absent, }

}

class dbp_vserver_etch inherits dbp_vserver_etch_no_ssmtp {
	include ssmtp
}

class dbp_vserver_sarge inherits dbp_base {

	apt { default_apt:
		clean => always,
	}

	service { [ "bootlogd", "bootmisc.sh", "checkfs.sh", "checkroot.sh",
			"console-screen.sh", "halt", "hostname.sh",
			"hwclock.sh", "hwclockfirst.sh", "ifupdown",
			"ifupdown-clean", "keymap.sh", "klogd", "makedev",
			"modutils", "mountall.sh", "mountnfs.sh",
			"mountvirtfs", "networking", "procps.sh", "reboot",
			"rmnologin", "single", "stop-bootlogd", "umountfs",
			"umountnfs.sh", "urandom" ]:
		enable => false
	}

}

class dbp_etch inherits dbp_base { 

	apt { default_apt: }

	package { [dhcp-client, dlocate, w3m, wget, smartmontools, acpi, tcpdump]:
		ensure => installed
	}
	include backuppc_client
	include ntp_client
	include default_user_sudo

	File["/etc/cron.hourly/puppet"] { content => "#!/bin/bash\ntime nice puppetd --test \"$*\"; if [ -e /etc/vservers ] ; then for i in \$(cat /etc/vservers/*/name) ; do echo \$i; time nice vserver \$i exec puppetd --test \"$*\"; done; fi\n" }

}


# use only for legacy hosts chip and diode
class dbp_sarge inherits dbp_base { 

	include apt_sarge
	include backuppc_client
	include ntp_client
	include default_munin_node
	include ssh_server

	File["/etc/cron.hourly/puppet"] { content => "#!/bin/bash\ntime nice puppetd --test \"$*\"; if [ -e /etc/vservers ] ; then for i in \$(cat /etc/vservers/*/name) ; do echo \$i; time nice vserver \$i exec puppetd --test \"$*\"; done; fi\n" }

}

class dbp inherits dbp_base {

	apt { default_apt: }

	package { [dhcp-client, dlocate, w3m, wget, smartmontools, acpi,
			tcpdump]:
		ensure => installed
	}

	include ntp_client
}

define vim() {
	package { vim: ensure => installed }

	# wenn vim 7.0 in etch ist, muss das $vimrc ersetzt werden
	# ud vimrc.local gelöscht
	# $vimrc = $dv ? {
	# 	sarge => "/etc/vim/vimrc.local",
	# 	etch  => "/etc/vim/vimrc"
	# }
	$vimrc = $dv ? {
		sarge => "/etc/vim/vimrc.local",
		etch => "/etc/vim/vimrc",
		"" => "/etc/vim/vimrc.local"
	}

	file { $vimrc:
		source => "$fileserver/$dv/vimrc",
		mode => 0644, owner => root, group => root,
		require => Package[vim]
	}
}

class default_user {
	user { david:
		allowdupe => false,
		comment => "David Schmitt",
		ensure => present,
		gid => 1234,
		home => "/home/david",
		shell => "/bin/bash",
		uid => 1234
	}
	group { david:
		allowdupe => false,
		ensure => present,
		gid => 1234
	}
	file {
		"/home/david/":
			ensure => directory,
			# keep 0751 to enable public_html acces and similar things
			mode => 0751, owner => 1234, group => 1234;
		"/home/david/.toprc":
			source => "$fileserver/home/david/.toprc",
			mode => 0640, owner => 1234, group => 1234;
		"/home/david/.bashrc":
			source => "$fileserver/home/david/.bashrc",
			mode => 0640, owner => 1234, group => 1234;
		"/home/david/.ssh":
			ensure => directory,
			mode => 0700, owner => 1234, group => 1234;
		"/home/david/.ssh/config":
			source => "$fileserver/home/david/.ssh/config",
			mode => 0600, owner => 1234, group => 1234;
	}
}

class default_user_sudo {
	append_if_no_such_line { david_sudoer:
		file => "/etc/sudoers",
		line => "david ALL=(ALL) ALL",
		require => Package[sudo]
	}
}

class inetd {
	package { openbsd-inetd: ensure => installed }
	file { "/etc/inetd.conf":
		checksum => md5,
		require => Package[openbsd-inetd]
	}
	file { "/etc/services":
		checksum => md5,
	}
	service { openbsd-inetd:
		ensure => running,
		pattern => inetd,
		subscribe => [ File["/etc/inetd.conf"], File["/etc/services"] ]
	}
}
