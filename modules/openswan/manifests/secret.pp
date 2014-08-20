define openswan::secret (
  $local_ip = '%any',
  $remote_ip,
  $secret
) {
  file {
    "/etc/ipsec.d/$name.secrets":
      ensure  => present,
      content => "${local_ip} ${remote_ip}: PSK \"${secret}\"\n",
      require => Package['openswan'],
  }
}
