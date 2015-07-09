package { 'fail2ban':
  ensure => present,
}

class { 'locales': }

package { 'postgresql-server-dev-all':
  ensure => present,
}

package { 'npm':
  ensure => present,
}

package { 'nodejs':
  ensure => present,
}

user { 'trader':
  ensure => present,
  password => '$1$D5KK5H7a$OCs4OnweVdEe/ll2ZevPd1',
  shell => '/bin/bash',
  managehome => true,
  before => Class['ssh::server', 'sudo'],
}

ssh_authorized_key { 'home_computer_key':
  ensure => present,
  user => 'trader',
  key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD5jD7/p8luC+QyItm21oHZxunN4kjqkrZzieIOaPnPdbIRXFfkwbs4UMd2pch0d5g/CwRS0NN2lPsfYw2oN7Y7xM+x28iOU5Baw8s+K3EsZoiJv5oIewKvS+cOkmWbKCLwPxthB5qLvtLdeSKaEHbXueQCH/sJjZ20EE0DAC5tltZYvhcSoL/2Pi5sGmCboBvOkYvpXUtJuSsDegETJK4off1zysFuE2AWCZ3BSEDjIjvegVtH/5q0ED99jUFY769lZzRbjcmzWVqAmY/Pn8cWWCAeH2lvd9JAVL6dvyYl7kftbvi6SHvoJ56Km1Fn2KQwVT8EviIsG6gNlxrZfYVn',
  type => 'rsa',
}

ssh_authorized_key { 'office_computer_key':
  ensure => present,
  user => 'trader',
  key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDJCbc4Sv6r8NcQSNc8T1dLoYnLDsNO0Kd/AwSIXE6UjF2X/gC1+9bLtIn4wUppLJzr85+2ltDEBl2peROJRuCk8uFVye1ip5Gyz5JLnpeIzUxYIowa780KXgUdbZdlp/P6uNXlbEGqo9xAUHd2sPfGaVRG7zsuRiolzAZTp/FeLtfJLwd7jp09dV08xUj2tHdFicnJNnnJTmx+3YdSPq0VOpXlvYc9xHms+VasVhg/bLl6IfqXxZ1cC0BSUfkQrIIz+QUZP8vNe+VD6wJaq4vGBX49IrRVMqnZIZbplMJKQcZfR/hGzOWRn7dZ/b8ZYykR618yb4FHYTZQCvS89Kuj',
  type => 'rsa',
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
    'trader' => {
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
    #'PermitRootLogin' => 'no',
    #'AllowUsers' => 'trader@*.dynamic.hispeed.ch trader@pc9689.psi.ch',
  },
}

include apt

class { 'postgresql::server':
  require => Class['locales'],
}

postgresql::server::db { 'analysis_db':
  user => 'analysis',
  password => 'analysis',
}

vcsrepo { "/home/trader/analysis-frontend":
  ensure   => present,
  provider => git,
  source   => "https://github.com/galilean-traders/analysis-frontend.git",
  user => "trader"
}

vcsrepo { "/home/trader/rzmq-workers":
  ensure   => present,
  provider => git,
  source   => "https://github.com/galilean-traders/rzmq-workers.git",
  user => "trader"
}

vcsrepo { "/home/trader/analysis":
  ensure   => present,
  provider => git,
  source   => "https://github.com/Enucatl/analysis.git",
  user => "trader"
}

include pyenv

pyenv::install { 'trader':
  require => User["trader"]
}

pyenv::compile { 'compile 2.7.9 trader':
  user => "trader",
  python => "2.7.9",
}

class { 'r': }

r::package { 'rzmq': }
r::package { 'rjson': }
r::package { 'xts': }
r::package { 'TTR': }
r::package { 'argparse': }
r::package { 'data.table': }
