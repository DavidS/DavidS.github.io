# logcheck.pp - a class for carrying logcheck modifications
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


class logcheck {
	preseeded_package { logcheck: }

#	file { "/etc/logcheck/":
#		source => "$fileserver/logcheck",
#		recurse => true,
#		group => logcheck,
#	}
	File {
		mode => 0640, owner => root, group => logcheck,
	}
		
	file {
		"/etc/logcheck/ignore.d.server/puppet-pp":
			source => "$fileserver/logcheck/ignore.d.server/puppet-pp";
		"/etc/logcheck/violations.ignore.d/puppet-pp":
			source => "$fileserver/logcheck/violations.ignore.d/puppet-pp";
	}
}

