# xen.pp - collect xen specific hacks here
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# install the proper libc6 and add a config to avoid annoying kernel messages
# (and probably a performance leech)

class xen_guest {
	package { libc6-xen: ensure => installed }
	config_file { "/etc/ld.so.conf.d/nosegneg.conf":
		content => "hwcap 0 nosegneg\n"
	}
}
