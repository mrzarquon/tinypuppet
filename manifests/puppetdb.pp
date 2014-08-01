class tinypuppet::puppetdb (
  $ca_certname = $::fqdn,
) {

  Ini_setting {
    path    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
    ensure  => present,
    section => 'jetty',
    require => Package['pe-puppetdb','pe-puppetdb-terminus'],
    notify  => Service['pe-puppetdb'],
  }

  ini_setting { 'puppetdb-host':
    setting => 'host',
    value    => '0.0.0.0'
  }
  ini_setting { 'puppetdb-port':
    setting => 'post',
    value    => '8080',
  }
  ini_setting { 'puppetdb-ssl-host':
    setting => 'ssl-host',
    value   => '0.0.0.0',
  }
  ini_setting { 'puppetdb-ssl-port':
    setting => 'ssl-port',
    value   => '8081',
  }
  ini_setting { 'puppetdb-ssl-key':
    setting => 'ssl-key',
    value   => '/etc/puppetlabs/puppetdb/ssl/private.pem',
  }
  ini_setting { 'puppetdb-ssl-cert':
    setting => 'ssl-cert',
    value   => '/etc/puppetlabs/puppetdb/ssl/public.pem',
  }
  ini_setting { 'puppetdb-ssl-ca-cert':
    setting => 'ssl-ca-cert',
    value   => '/etc/puppetlabs/puppetdb/ssl/ca.pem',
  }

  File {
    require => Exec['generate_cert'],
  }

  file { '/etc/puppetlabs/puppetdb/ssl/private.pem':
    ensure => file,
    owner  => pe-puppetdb,
    group  => pe-puppetdb,
    source => "file:///etc/puppetlabs/puppet/ssl/private_keys/${ca_certname}.pem",
  }
  file { '/etc/puppetlabs/puppetdb/ssl/public.pem':
    ensure => file,
    owner  => pe-puppetdb,
    group  => pe-puppetdb,
    source => "file:///etc/puppetlabs/puppet/ssl/certs/$ca_certname}.pem",
  }
  file { '/etc/puppetlabs/puppetdb/ssl/ca.pem':
    ensure => file,
    owner  => pe-puppetdb,
    group  => pe-puppetdb,
    source => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem',
  }

  ini_setting { 'puppetdb-terminus-server':
    path    => '/etc/puppetlabs/puppet/puppetdb.conf',
    section => 'main',
    setting => 'server',
    value   => $ca_certname,
    ensure  => 'present',
    notify  => Service['pe-bootstrap'],
  }

  ini_setting { 'puppetdb-terminus-port':
    path    => '/etc/puppetlabs/puppet/puppetdb.conf',
    section => 'main',
    setting => 'port',
    value   => '8081',
    ensure  => 'present',
    notify  => Service['pe-bootstrap'],
  }

  file { '/etc/puppetlabs/puppet/routes.yaml':
    ensure => 'file',
    owner => 'pe-puppet',
    content => "---
master:
  facts:
    terminus: puppetdb
    cache: yaml",
  }

  service { 'pe-puppetdb':
    ensure => running,
    enable => true,
    require => Package['pe-puppetdb'],
  }

  package { ['pe-puppetdb', 'pe-puppetdb-terminus']:
    ensure => present,
  }

}
