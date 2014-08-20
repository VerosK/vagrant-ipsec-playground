class openswan {
  package {
    'openswan':
      ensure => installed,
  }

  service {
    'ipsec':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
  }

  file {
    '/etc/ipsec.conf':
      ensure  => present,
      mode    => '0600',
      owner   => 'root',
      notify  => Service['ipsec'],
      require => Package['openswan'],
      content => template('openswan/openswan.conf.erb'),
  }
}
