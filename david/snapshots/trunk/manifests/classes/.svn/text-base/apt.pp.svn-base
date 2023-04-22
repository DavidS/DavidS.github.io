# apt.pp - common components and defaults for handling apt
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
#
# With hints from
# 	Micah Anderson <micah@riseup.net>
# 	* backports key

# workaround for preseeded_package
file { "/var/cache": ensure => directory }
file { "/var/cache/local": ensure => directory }
file { "/var/cache/local/preseeding/": ensure => directory }

define preseeded_package ($content = "") {

	$seedfile = "/var/cache/local/preseeding/$name.seeds"
	$real_content = $content ? {
		"" => template ( "$dv/$name.seeds" ),
		Default => $content
	}

	file{ $seedfile:
		content => $real_content,
		mode => 0600, owner => root, group => root,
	}
	
	package { $name:
		ensure => installed,
		responsefile => $seedfile,
		require => File[$seedfile],
	}

}

define apt ($dv = "etch", $clean = "auto") {
	file { "/etc/apt/sources.list":
		source => "$fileserver/$dv/sources.list",
		checksum => md5,
		mode => 0644, owner => root, group => root
	}

	file { "/etc/apt/preferences":
		source => "$fileserver/$dv/preferences",
		mode => 0644, owner => root, group => root
	}

	append_if_no_such_line { dselect_expert:
		file => "/etc/dpkg/dselect.cfg",
		line => expert
	}

	config_file { "/etc/apt/apt.conf.d/local-conf":
		content => "APT::Get::Show-Upgraded true;\nDSelect::Clean $clean;\n",
	}

	exec { "/usr/bin/apt-get -y update #on refresh":
		refreshonly => true,
		subscribe => [ File["/etc/apt/sources.list"], File["/etc/apt/preferences"] ]
	}

	exec { "/usr/bin/apt-get -y update && /usr/bin/apt-get autoclean #hourly":
		require => [ File["/etc/apt/sources.list"], File["/etc/apt/preferences"] ],
		alias => apt-get_update
	}

	case $dv {
		etch: {
			## This package should really always be current
			package { "debian-archive-keyring":
				ensure => latest,
			}
			# This key was downloaded from
			# http://backports.org/debian/archive.key
			# and is needed to verify packages from bp.o
			file { "/etc/apt/backports.key":
				source => "$fileserver/backports.key",
				mode => 0444, owner => root, group => root,
			}
			exec { "/usr/bin/apt-key add /etc/apt/backports.key":
				refreshonly => true,
				subscribe => File["/etc/apt/backports.key"],
			}
		}
	}
}

class apt_sarge { apt { default_apt: dv => sarge } }
class apt_etch { apt { default_apt: dv => etch } }

Package { require => Exec[ apt-get_update ] }
