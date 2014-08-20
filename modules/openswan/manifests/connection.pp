define openswan::connection (
  $left,
  $right,
  $esp,
  $foreignip,
  $localtestip,
  $ike,
  $rightsubnet = undef,
  $rightsubnets = undef,
  $leftsubnet = undef,
  $leftsubnets = undef,
  $leftid = undef,
  $rightid = undef,
  $leftsourceip = undef,
  $rightsourceip = undef,
  $salifetime = '8h',
  $ikelifetime = '1h',
  $dpd = false,
  $dpddelay = 30,
  $dpdtimeout = 120,
  $dpdaction = 'hold',
) {
#  if (!$leftsubnet) and (!$leftsubnets) {
#    fail( '$leftsubnets and $leftsubnet cannot be both empty' )
#  }
#  if (!$rightsubnet) and (!$rightsubnets) {
#    fail( '$rightsubnets and $rightsubnet cannot be both empty' )
#  }

  if ($dpd == true) {
    if (!is_integer($dpdtimeout) and (!$dpdtimeout == undef)) {
      fail( '$dpdtimeout must be an integer' )
    }
    if (!is_integer($dpddelay) and (!$dpddelay == undef)) {
      fail( '$dpddelay must be an integer' )
    }

    if (!$dpdaction == 'hold') or (!$dpdaction == 'clear') or (!$dpdaction == 'restart') or (!$dpdaction == 'restart_by_peer') {
      fail( '$dpdaction must be either hold, clear, restart or restart_by_peer' )
    }
  }

  cron {
    "keepalive-${name}":
      ensure  => absent,
      command => "/bin/ping -c 4 -I ${localtestip} ${foreignip} &> /dev/null || (/usr/sbin/ipsec auto --down ${name} && /usr/sbin/ipsec auto --up ${name} && /usr/bin/logger -t openswan VPN to ${name} relaunched) &> /dev/null",
      require => Package['openswan'],
      minute  => '*/10',
  }
  file {
    "/etc/ipsec.d/${name}.conf":
      ensure  => present,
      content => template('openswan/connection.erb'),
      notify  => Exec["ipsec-reload-${name}"],
      require => Package['openswan'],
  }
  exec {
    "ipsec-reload-${name}":
      command     => "/usr/sbin/ipsec auto --replace ${name}",
      refreshonly => true,
      require     => Service['ipsec'],
  }

}
