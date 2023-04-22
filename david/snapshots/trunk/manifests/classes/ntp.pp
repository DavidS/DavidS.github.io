# ntp.pp - Classes and definitions for NTP service
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


class ntp_client {
	package { ntp : ensure => installed, }

	# Perhaps this should go to the servers themselves, but I'm too lazy
	$ntp_chip = $fqdn ? { "chip.mariatreu.at" => absent, default => "ntp_" }
	$ntp_diode = $fqdn ? { "diode.black.co.at" => absent, default => "ntp_" }
	$ntp_time = $fqdn ? { "time.uni-ak.ac.at" => absent, default => "ntp_" }

	munin::plugin {
		[
			"ntp_chip.mariatreu.at", "ntp_diode.black.co.at",
			"ntp_time.uni-ak.ac.at"
		]:
				ensure => "ntp_",
				script_path => "/usr/local/bin"
				;
		# argl
		ntp_ns1_uni_ak_ac_at: ensure => absent;
		ntp_time_uni_ak_ac_at: ensure => absent;
		ntp_chip_mariatreu_at: ensure => absent;
		ntp_diode_black_co_at: ensure => absent;
		ntp_smtpscanner_uni_ak_ac_at: ensure => absent;
	}

	file { "/etc/ntp.conf":
		source => "$fileserver/ntp.conf",
		mode => 0644, owner => root, group => root,
		require => Package[ntp],
	}
	service{ ntp:
		ensure => running,
		pattern => ntpd,
		subscribe => File["/etc/ntp.conf"],
	}
}

class ntp_server inherits ntp_client {
	File["/etc/ntp.conf"] { source => "$fileserver/ntp.server.conf", }
	munin::plugin {
		[
			"ntp_POOL_1",
			"ntp_time.inode.at",
			"ntp_ntp2b.mcc.ac.uk",
			"ntp_fartein.ifi.uio.no",
			"ntp_pluto.fips.at",
			"ntp_ntp1.nack.at"
		]:
			ensure => "ntp_",
			script_path => "/usr/local/bin"
			;
	}
}

