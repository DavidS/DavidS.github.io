# ssh.pp - common ssh related components
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


class ssh_base {
	file { "/etc/ssh":
		ensure => directory,
		mode => 0755
	}
}

class ssh_client inherits ssh_base {
	# Now collect everyone else's keys
	Sshkey <<||>>

	package{ "openssh-client": ensure => installed, before => File["/etc/ssh"] }
}

class ssh_server inherits ssh_base {

	# every server is a client too
	include ssh_client

	package{ "openssh-server": ensure => installed }

	service { ssh:
		ensure => running,
		pattern => "sshd",
		require => Package["openssh-server"],
	}

	# Now add the key, if we've got one
	case $sshrsakey_key {
		"": { 
			err("no sshrsakey on $fqdn")
		}
		default: {
			#@@sshkey { "$hostname.$domain": type => ssh-dss, key => $sshdsakey_key, ensure => present, }
			debug ( "Storing rsa key for $hostname.$domain" )
			@@sshkey { "$hostname.$domain": type => ssh-rsa, key => $sshrsakey_key, ensure => present }
		}
	}

	$real_ssh_port = $ssh_port ? { '' => 22, default => $ssh_port }

	sshd_config{ "Port": ensure => $real_ssh_port }

	nagios2::service{ "ssh_port_${real_ssh_port}": check_command => "ssh_port!$real_ssh_port" }

}

define sshd_config($ensure) {
	replace { "sshd_config_$name":
		file => "/etc/ssh/sshd_config",
		pattern => "^$name +(?!\\Q$ensure\\E).*",
		replacement => "$name $ensure # set by puppet",
		notify => Service[ssh],
	}
}

