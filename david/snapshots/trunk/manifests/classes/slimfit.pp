# slimfit.pp - reduces disk usage on the node
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


class slimfit {
	# automatically uses locale-gen data to initialize
	package { localepurge: ensure => installed, require => Package[locales] }

	file { "/etc/cron.daily/puppet_localepurge":
		content => "#!/bin/bash\n/usr/sbin/localepurge\n",
		mode => 0755, owner => root, group => root,
	}
	
}

