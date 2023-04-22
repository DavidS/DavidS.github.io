# asterisk.pp - things we need on a telephony server
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class asterisk {
	# ensure basic packages are installed
	package { 
		[ asterisk, zaptel ]: ensure => installed
	}

	# support package for fax2mail/mail2fax
	package { "mpack": ensure => installed, }
}

