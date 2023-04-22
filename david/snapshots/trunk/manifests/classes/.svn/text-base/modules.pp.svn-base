# modules.pp: Define components for handling kernel modules
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# With input from:
#   * Adam Kosmin <akosmin@247realmedia.com>
#
# On Debian this will cause the module to be loaded on boot.
# Other systems will load it when puppet runs the next time
#
# Patches welcome


# Examples:
# 	load and configure the dummy module:
#	 	kernel_module { dummy: options => "numdummies = 20" }
#	suppress ipv6:
#		kernel_module { ipv6: ensure => absent }

define kernel_module($ensure = present, $options = '' ) {
	# where to put the modprobe configuration
	$modprobe_file = "/etc/modprobe.d/pp-${name}"
	# a little template how to configure the module options
	$options_real = $options ? {
		'' => '# empty placeholder by puppet\n',
		default => "options ${name} ${options}\n"
	}
	# true if the module is loaded
	# note the space at the end of the regex as record seperator
	$module_check = "/sbin/lsmod | grep -q '^${name} '"

	file { $modprobe_file:
		ensure => $ensure,
		content => $options_real,
		mode => 0644, owner => root, group => root,
	}

	case $ensure {
		default : { err ( "unknown ensure value $ensure" ) }
		present: {
			exec { "/sbin/modprobe $name":
				unless => $module_check,
				subscribe => File[$modprobe_file]
			}
		}
		absent: {
			exec { "/sbin/rmmod $name":
				onlyif => $module_check,
				subscribe => File[$modprobe_file]
			}
		}
	}

	case $operatingsystem {
		Debian: {
			line { "ensure_module_$name":
				file => "/etc/modules",
				line => $name,
				ensure => $ensure,
				# ensure that the module is only configured
				# here after modprobe is ready for this
				require => File[$modprobe_file],
			}
		}
	}
}

