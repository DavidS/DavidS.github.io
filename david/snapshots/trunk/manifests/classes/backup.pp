# backuppc.pp - basic components for configuring backuppc
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


define backuppc_setting ($val) {

	$p1='^\s*\$Conf\{'
	# (#...)? for idempotency and not killing comments at end of line
	$p2='\}\s*=\s*(?!'
	$p3=')[^;]*;.*$'
	$p = template("backuppc_set_pattern.erb")

	$r1='\$Conf{'

	replace { "backuppc_set_$name":
		file => "/etc/backuppc/config.pl",
		pattern => "$p1$name$p2$val$p3",
		#pattern => $p,
		replacement => "$r1$name} = $val; # managed by puppet"
	}
}

class backuppc_server {
	include apache2
	include ssh_client

	package { [ backuppc, libfile-rsyncp-perl, rsync]:
		ensure => present
	}

	file { "/var/lib/backuppc/.ssh":
		ensure => directory, mode => 0700,
		owner => backuppc, group => backuppc
	}

	backuppc_setting { PingMaxMsec: val => "40"; }
	backuppc_setting { FullKeepCnt: val => "3"; }
	backuppc_setting { BackupFilesExclude: val => '[ "\/proc", "\/sys", "\/backup", "\/media", "\/mnt", "\/var\/cache\/apt\/archives" ]' }
	# TODO: collect backuppc_client definitions into hosts file
}

class backuppc_client {

	include ssh_server

	package { rsync: 
		ensure => installed
	}

	file { "/var/local/abackup/":
		ensure => directory, mode => 700,
		owner => abackup, group => nogroup
	}

	file { "/var/local/abackup/.ssh":
		ensure => directory, mode => 700,
		owner => abackup, group => nogroup
	}

	file { "/var/local/abackup/.ssh/authorized_keys":
		ensure => present, mode => 600,
		owner => abackup, group => nogroup,
		source => "$fileserver/abackup_authorized_key"
	}

	user { "abackup":
		allowdupe => false,
		ensure => present,
		home => "/var/local/abackup/",
		shell => "/bin/bash",
		gid => nogroup
	}

	append_if_no_such_line { abackup_sudoers:
		file => "/etc/sudoers",
		line => "abackup ALL=(ALL) NOPASSWD: /usr/bin/rsync --server --sender --numeric-ids --perms --owner --group --devices --links --times --block-size=2048 --recursive -D *",
		require => Package[sudo]
	}

	# TODO: export hosts file

}

