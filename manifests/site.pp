
notify{"Started on  ${fqdn}": }

# set default
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

host { "${fqdn}":
    ip => $ipaddress_eth1,
    ensure => present,
}

include ::openswan

$nodes = hiera("nodes")

openswan::secret{"east-west":
  local_ip => 'east',
  remote_ip => 'west',
  secret => 'yeephoiL5wae5oofieTohghied3rahSa'
}

openswan::secret{"west-east":
  local_ip => 'west',
  remote_ip => 'east',
  secret => 'yeephoiL5wae5oofieTohghied3rahSa'
}

openswan::connection{"east-west":
  left    => $nodes['east'],
  right   => $nodes['west'],
  esp     => 'aes256-sha1;modp1536',
  ike     => 'aes256-sha1;modp1536',
  foreignip => 'east',
  localtestip => 'west',
}