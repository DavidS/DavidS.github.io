# leshaper.pp - Install lefant's shaper and configure it
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# set $uplink_speed and $downlink_speed for this device before including this
# class. 
# If your uplink interface is not called "uplink" you can override this
# with $shaper_if
# This also needs the package iproute, which I install somewhere else
class leshaper {

	case $uplink_speed {
		'': { err ( '$uplink_speed not set' ) }
	}
	case $downlink_speed {
		'': { err ( '$downlink_speed not set' ) }
	}
	#case $shaper_if { '': { err ( '$shaper_if not set' ) } }

	file { 
		"/etc/init.d/leshaper": 
			source => "${fileserver}/leshaper",
			mode => 0755, owner => root, group => root;
		"/etc/default/leshaper":
			content => template("default_leshaper"),
			mode => 0644, owner => root, group => root;
	}

	service { leshaper:
		ensure => running,
		hasstatus => true,
		require => Package[iproute],
		subscribe => [ File["/etc/init.d/leshaper"], File["/etc/default/leshaper"] ],
	}
}
