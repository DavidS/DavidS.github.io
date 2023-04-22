# mysql.pp - mysql server and phpmyadmin
# common.pp - common definitions which are independent of the system
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


class mysql_server {
	package { "mysql-server":
		ensure => installed,
	}
	munin::plugin {
		[mysql_bytes, mysql_queries, mysql_slowqueries, mysql_threads]:
	}

	service { mysql:
		ensure => running,
		pattern => "mysqld",
		require => Package["mysql-server"],
	}
}

class phpmyadmin {
	include apache2
	include no_default_apache2_site

	package { phpmyadmin: ensure => installed }
	file { "/etc/apache2/sites-available/phpmyadmin":
		content => template ("phpmyadmin-site.erb"),
		mode => 664, owner => root, group => root,
		require => Package["apache2"],
		notify => Exec["reload-apache2"],
	}
	apache2_site { "phpmyadmin": ensure => present, }
}
