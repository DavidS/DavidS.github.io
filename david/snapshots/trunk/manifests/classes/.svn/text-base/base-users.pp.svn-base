# base_users.pp - a registry of basic users as needed by various services
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# this is used to avoid uid clashes
#
# currently unused because I have no time to find, implement and change all
# users

@user { "Debian-exim":
	allowdupe => false,
	ensure => present,
	gid => 103,
	home => "/var/spool/exim4",
	shell => "/bin/false",
	uid => 101
}

@group { "Debian-exim":
	allowdupe => false,
	ensure => present,
	gid => 103
}

