$user = 'matteo'

ssh_authorized_key { 'ssh_key':
  ensure => present,
  user => $user,
  key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC8RAx6+Z0QOFFv3ALGioOkinGyrZt6qNsrHe17oJzdbIom51Klz610va41hIhG6YiFlyy3ODubGCkYlzWSSEWA/3a20bqCVsJHwcS/k5DCw5OusYWQnGRVBg1Gq/V90buyVfVFRJc2JWJC+daJ3lfVSLgGLHNeVB7CfJNCb49xbGCHu4Z623PZ08fBrknsY16UmDYaHhxBMUc/pLnThS42hGWqWEjso6EXwhQMjMTLXvmM04fM2cpQs9/W6TeRJUdxG2/e1Nmdo26k6Xvy1T6lvULiYbIW/blnLFE2v4sP1zSTSDPwxjYH6XK6Ngn7PPjDC4NOHyeezfXcEU8pQAN/',
  type => 'rsa',
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

user { $user:
  ensure => present,
  shell => '/bin/bash',
  managehome => true,
  before => Class['ssh::server', 'sudo'],
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
    $user => {
      ensure => absent,
    },
  },
}

include ufw

ufw::allow { "allow-ssh-from-all":
  port => 22,
}

ufw::allow { "allow-http":
  port => 80
}

ufw::allow { "allow-https":
  port => 443
}

class { 'ssh::server':
  options => {
    'PasswordAuthentication' => 'no',
  },
}

include apt

class{"nginx":
    manage_repo => true,
    package_source => 'nginx-mainline'
}

nginx::resource::server{'enucatllendingbot.duckdns.org':
}

nginx::resource::location{ "/${user}/":
  proxy => "http://upstream_${user}/" ,
  server => 'enucatllendingbot.duckdns.org'
}

nginx::resource::upstream { "upstream_${user}":
  members => [
    '127.0.0.1:8000',
  ],
}
cron::hourly { 'duckdns_hourly':
  user        => $user,
  command     => '~/duckdns.sh > /dev/null 2>&1',
}
