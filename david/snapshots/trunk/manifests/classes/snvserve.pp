# From the prm

# Example usage:
#   svnserve { dist:
#       source => "https://reductivelabs.com/svn",
#       path => "/dist",
#       user => "puppet",
#       password => "mypassword"
#   }
define svnserve($source, $path, $user = false, $password = false) {
    file { $path:
        ensure => directory,
        owner => root,
        group => root
    }
    $svncmd = $user ? {
        false => "/usr/bin/svn co --non-interactive $source/$name .",
        default => "/usr/bin/svn co --non-interactive --username $user --password '$password' $source/$name ."
    }
    exec { "svnco-$name":
        command => $svncmd,
        cwd => $path,
        require => [ File[$path], Package[subversion] ],
        creates => "$path/.svn"
    }
    exec { "svnupdate-$name":
        command => "/usr/bin/svn update",
        require => Exec["svnco-$name"],
        onlyif => "/usr/bin/svn status -u --non-interactive | /bin/grep '\*'",
        cwd => $path
    }
}

# $Id: svnserve.pp 182 2006-07-05 18:05:11Z luke $
