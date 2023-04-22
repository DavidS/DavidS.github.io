# vserver.pp - vserver definitions
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


class vserver_host inherits dbp_etch {

	# create dummy interfaces on the host
	append_if_no_such_line { modules_dummy:
		file => "/etc/modules",
		line => dummy
	}
	
	# create dummy interfaces on the host
	file { "/etc/modprobe.d/local-dummy":
		content => "options dummy numdummies=20\n",
		mode => 0644, owner => root, group => root, backup => server
	}

	package { [ util-vserver, debootstrap ]: ensure => installed, }
}

