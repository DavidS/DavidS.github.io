# exim4.pp - spamscanning and virus scanning included
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


$BASEDIR = "/etc/exim4/tests"

define exim4_testdir() {
	file { "$BASEDIR/$name": ensure => directory, }
}

class exim4_host {

	package { [exim4-daemon-heavy, clamav, clamav-freshclam, spamc, psmisc]:
		ensure => installed
	}

	file { "/etc/exim4/":
		source => "$fileserver/exim4/",
		recurse => true,
	}

	update_exim4_param {
		dc_use_split_config: ensure => true;
		dc_eximconfig_configtype: ensure => internet;
	}

	# dummy definition to subscribe
	file { "/etc/exim4/update-exim4.conf.conf": checksum => md5 }
	service{ exim4:
		ensure => running,
		subscribe => [ File["/etc/exim4"],
			File["/etc/exim4/update-exim4.conf.conf"],
			Package["exim4-daemon-heavy"] ],
	}

	# For each exim4_test, define a virtual testdir here
	# and realize it only when doing the test.
	@exim4_testdir { [ bt, bh, bhc ]: }

	# make the exim4 and ssmtp classes conflict 
	package { ssmtp: ensure => absent }

	# enable eximstats processing
	file { "/etc/cron.daily/puppet_exim4stats":
		content => "!#/bin/sh\neximstats </var/log/exim4/mainlog | mail -s\"\$(hostname --fqdn) Daily email activity report\" root",
		mode => 755, owner => root, group => root,
	}

	munin::plugin { [ "exim_mailqueue", "exim_mailstats" ]: ensure => present }
	
}

class spamassassin {

	package{ spamassassin: ensure => installed, }

	replace { spamd_enable:
		file => "/etc/default/spamassassin",
		pattern => "ENABLED=0",
		replacement => "ENABLED=1",
	}

	replace { spamd_options:
		file => "/etc/default/spamassassin",
		pattern => 'OPTIONS="--create-prefs.*"',
		replacement => 'OPTIONS="--max-children 5 --helper-home-dir --listen-ip=192.168.0.4 --allowed-ips=192.168.0.4 --username=spamd --nouser-config --nolocal --max-conn-per-child=5 --create-prefs"',
	}

	file {
		"/etc/default/spamassassin": checksum => md5;
		"/var/lib/spamd/":
			ensure => directory,
			owner => spamd, group => nogroup,
			mode => 0600, recurse => true;
	}


	user { spamd:
		uid => 109, gid => nogroup,
		home => "/var/lib/spamd",
		shell => "/bin/false",
	}

	service { spamassassin:
		ensure => running,
		subscribe => File[ "/etc/default/spamassassin" ],
		pattern => spamd,
		#require => [ Replace[spamd_enable], Replace[spamd_options] ],
	}
		
}

define exim4_test($test = "bt", $source_ip = "", $input = "")
{
	$TESTDIR = "$BASEDIR/$test"

	case $test {
		bt: {
			Exim4_testdir <| title == bt |>
			file { "$TESTDIR/$name":
				ensure => present,
			}
		}
	}
}

define update_exim4_param($ensure) {

	replace { "update_exim4_param_$name":
		file => "/etc/exim4/update-exim4.conf.conf",
		pattern => "^$name='\''(?!\Q$ensure\E)[^'\'']*'\''.*",
		replacement => "$name='\''$ensure'\''",
		notify => Service[exim4],
	}
}

