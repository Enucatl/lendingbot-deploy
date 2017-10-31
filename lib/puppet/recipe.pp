class { "apt":
  update => {
    frequency => "daily"
  }
}

package { [
  'screen', 
  'python-requests',
  'python-numpy',
  'python-hypothesis',
  'python-pip',
  'python-tz',
  'fail2ban',
]:
  ensure => present,
}

include ufw

ufw::allow { "allow-ssh-from-all":
  port => 22,
}

ufw::allow { "allow-http":
  port => 80,
}

ufw::allow { "allow-https":
  port => 443,
}

class { 'ssh::server':
  options => {
    'PasswordAuthentication' => 'no',
    'AcceptEnv' => '',
  },
}

class {"nginx":
    manage_repo => true,
    package_source => 'nginx-mainline'
}

nginx::resource::server{'enucatllendingbot.duckdns.org':
}

class { 'sudo':
  keep_os_defaults => false,
  defaults_hash => {
    env_reset => true,
    mail_badpass => true,
    secure_path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  },
  confs_hash => {
    'root' => {
      ensure => present,
      content => 'root ALL=(ALL) NOPASSWD: ALL'
    },
  }
}

define lendingbot_user (
  String $user=$title,
  String $ssh_key,
  Integer $port,
) {
  ssh_authorized_key { "${user}_ssh_key":
    ensure => present,
    user => $user,
    key => $ssh_key,
    type => 'rsa',
  }

  user { $user:
    ensure => present,
    shell => '/bin/bash',
    managehome => true,
    before => Class['ssh::server', 'sudo'],
  }

  sudo::conf { $user:
    ensure => absent,
  }

  nginx::resource::location{ "/${user}/":
    proxy => "http://upstream_${user}/" ,
    server => 'enucatllendingbot.duckdns.org'
  }

  nginx::resource::upstream { "upstream_${user}":
    members => [
      "127.0.0.1:$port",
    ],
  }

  cron::hourly { "duckdns_hourly_${user}":
    user        => $user,
    command     => '~/duckdns.sh > /dev/null 2>&1',
  }
}

lendingbot_user { 'matteo':
  port    => 8000,
  ssh_key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQC8RAx6+Z0QOFFv3ALGioOkinGyrZt6qNsrHe17oJzdbIom51Klz610va41hIhG6YiFlyy3ODubGCkYlzWSSEWA/3a20bqCVsJHwcS/k5DCw5OusYWQnGRVBg1Gq/V90buyVfVFRJc2JWJC+daJ3lfVSLgGLHNeVB7CfJNCb49xbGCHu4Z623PZ08fBrknsY16UmDYaHhxBMUc/pLnThS42hGWqWEjso6EXwhQMjMTLXvmM04fM2cpQs9/W6TeRJUdxG2/e1Nmdo26k6Xvy1T6lvULiYbIW/blnLFE2v4sP1zSTSDPwxjYH6XK6Ngn7PPjDC4NOHyeezfXcEU8pQAN/",
}

lendingbot_user { 'riccardo':
  port    => 8001,
  ssh_key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDuAUB0urFrpvrmtqeiUvoUAKjAO38os6bRZc+vsQuOUAqNcnCcZAzah8QkwXqTwZEfvLR6/qUz1fSqEREyB/mO5aEGJp8EVtrzcs4afnWVs0Xjapq8mMTNU8tAJ0nqMi3QNgRkDIlR0NkEqSj5nJS9mICbLHOXkOdeDLgurrDrrQ2brLccpatCaxEE0sQ3/PQitXYRXzWboYArfi9nc+uUEbdYcFNxXdoyqksLq82i66o7fel6xXyg62U3MmVIYxHpumkvZ2oxuYam6krLMLVeZPL1HIRaSLGVz9I0RWKVAD6e+/0Y4I62tO3ROZzJ/rHcFerLAc5d+7DIPOPAM6YR",
}
