# common.pp - common definitions which are independent of the system
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

define config_file ($content) {
	file { $name:
		mode => 0644,
		owner => root, group => root,
		content => $content,
		backup => server
	}
}

filebucket { server:
	server => "puppetmaster.black.co.at"
}

# don't distribute subversion metadata
File { ignore => '.svn' }

# Usage: 
# append_if_no_such_line { dummy_modules:
#	file => "/etc/modules",
#	line => dummy 
#	}
# 
# Ensures, that the line "line" exists in "file".
define append_if_no_such_line($file, $line) {
	exec { "/bin/echo '$line' >> '$file'":
		unless => "/bin/grep -Fx '$line' '$file'"
	}
}

# Usage:
# line { description:
# 	file => "filename",
# 	line => "content",
# 	ensure => {absent,present}
# }
define line($file, $line, $ensure) {
	case $ensure {
		default : { err ( "unknown ensure value $ensure" ) }
		present: {
			exec { "/bin/echo '$line' >> '$file'":
				unless => "/bin/grep -Fx '$line' '$file'"
			}
		}
		absent: {
			exec { "/usr/bin/perl -ni -e 'print unless /^\\Q$line\\E$/' '$file'":
				onlyif => "/bin/grep -Fx '$line' '$file'"
			}
		}
	}
}

# Usage:
#
# # replace the current port in /etc/munin/munin-node.conf
# # with a new, only disturbing the file when needed
# replace { set_munin_node_port:
# 	file => "/etc/munin/munin-node.conf",
# 	pattern => "^port (?!$port)[0-9]*",
# 	replacement => "port $port"
# }  
define replace($file, $pattern, $replacement) {
	$pattern_no_slashes = slash_escape($pattern)
	$replacement_no_slashes = slash_escape($replacement)
	exec { "/usr/bin/perl -pi -e 's/$pattern_no_slashes/$replacement_no_slashes/' '$file'":
		onlyif => "/usr/bin/perl -ne 'BEGIN { \$ret = 1; } \$ret = 0 if /$pattern_no_slashes/; END { exit \$ret; }' '$file'",
		alias => "exec_$name",
	}
}


# Replace a section marked by 
# comment_char {BEGIN,END} pattern
# with the given content
# if checksum is set to "none", no resource is defined for the edited file
define file_splice ($file, $pattern = "PUPPET SECTION", $comment_char = "#", $content = "", $input_file = "", $checksum = md5)
{
	case $checksum {
		"none": {}
		default: { file { $file: checksum => $checksum } }
	}

	# the splice command needs at least the BEGIN line in the file
	append_if_no_such_line { "seed-$file-$pattern":
		file => $file,
		line => "$comment_char BEGIN $pattern",
		require => File [ $file ],
	}

	case $content {
		"": {
			case $input_file {
				"": {
					fail ("either input_file or content have to be supplied")
				}
				default: {
					exec{ "/usr/local/bin/file_splice '$input_file' '$comment_char' '$pattern' $file":
						require => Append_if_no_such_line [ "seed-$file-$pattern" ],
						subscribe => [ File[$input_file], File[$file] ],
					}
				}
			}
		}
		default: {
			$splice_file = "$splice_dir/$name"
			file { $splice_file:
				mode => 0600, owner => root, group => root,
				content => $content,
				require => File [ $splice_dir ],
			}

			exec{ "/usr/local/bin/file_splice '$splice_file' '$comment_char' '$pattern' $file":
				require => Append_if_no_such_line [ "seed-$file-$pattern" ],
				subscribe => [ File [ $splice_file ], File[$file] ]
			}
		}
	}
}

# default drop dirs for various stuff
file {
	[ "/var/local",
	"/var/local/puppet",
	"/var/local/puppet/mail",
	"/var/local/puppet/nagios",
	"/var/local/puppet/munin-nodes" ]:
		ensure => directory, mode => 0755, owner => root, group => root, checksum => mtime;
}

$splice_dir = "/var/local/puppet/splice"
file { $splice_dir:
	ensure => directory,
	tag => "file_splice",
}

