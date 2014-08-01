class tinypuppet {

  Ini_setting {
    path   => '/etc/puppetlabs/puppet/puppet.conf',
    ensure => present,
  }

  ini_setting { 'certname':
    section => 'main',
    setting => 'certname',
    value   => 'master',
  }

  ini_setting { 'dns_alt_names':
    section => 'main',
    setting => 'dns_alt_names',
    value   => 'puppet,master,puppet.fqdn,master.fqdn',
  }
  ini_setting { 'server':
    section => 'main',
    setting => 'server',
    value   => 'master',
  }

  ini_setting { 'reports':
    section => 'master',
    setting => 'reports',
    value   => 'store,puppetdb',
  }
  ini_setting { 'storeconfigs':
    section => 'master',
    setting => 'storeconfigs',
    value   => 'true',
  }

  ini_setting { 'storeconfigs_backend':
    section => 'master',
    setting => 'storeconfigs_backend',
    value   => 'puppetdb',
  }

  exec { 'generate_cert':
    command => '/opt/puppet/bin/puppet cert generate --dns-alt-names puppet,master,puppet.fqdn,master.fqdn master',
    creates => '/etc/puppetlabs/puppet/ssl/public_keys/master.pem',
  }

}

class tinypuppetdb {
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
    source => 'file:///etc/puppetlabs/puppet/ssl/private_keys/master.pem',
  }
  file { '/etc/puppetlabs/puppetdb/ssl/public.pem':
    ensure => file,
    owner  => pe-puppetdb,
    group  => pe-puppetdb,
    source => 'file:///etc/puppetlabs/puppet/ssl/certs/master.pem',
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
    value   => 'master',
    ensure  => 'present',
  }

  ini_setting { 'puppetdb-terminus-port':
    path    => '/etc/puppetlabs/puppet/puppetdb.conf',
    section => 'main',
    setting => 'port',
    value   => '8081',
    ensure  => 'present',
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


include tinypuppet
include tinypuppetdb