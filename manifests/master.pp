class tinypuppet::master (
  $ca_certname = $::fqdn,
  $dns_alt_names = "puppet,${::fqdn}",
) {

  Ini_setting {
    path   => '/etc/puppetlabs/puppet/puppet.conf',
    ensure => present,
  }

  ini_setting { 'certname':
    section => 'main',
    setting => 'certname',
    value   => $ca_certname,
  }

  ini_setting { 'dns_alt_names':
    section => 'main',
    setting => 'dns_alt_names',
    value   => $dns_alt_names,
  }
  ini_setting { 'server':
    section => 'main',
    setting => 'server',
    value   => $ca_certname,
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

  ini_setting { 'hiera_config':
    section => 'main',
    setting => 'hiera_config',
    value   => '$confdir/hiera.yaml',
  }

  exec { 'generate_cert':
    command => "/opt/puppet/bin/puppet cert generate ${ca_certname}",
    creates => "/etc/puppetlabs/puppet/ssl/public_keys/${ca_certname}.pem",
  }

  file { '/etc/init.d/pe-bootstrap':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/tinypuppet/pe-bootstrap',
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure => file,
    source => 'puppet:///modules/tinypuppet/hiera.yaml',
  }
  file { '/etc/puppetlabs/puppet/environments':
    ensure => directory,
  }
  file { '/etc/puppetlabs/puppet/environments/pe_bootstrap':
    ensure => directory,
  }
  file { '/etc/puppetlabs/puppet/environments/pe_bootstrap/manifests':
    ensure => directory,
  }
  file { '/etc/puppetlabs/puppet/environments/pe_bootstrap/environment.conf':
    ensure  => file,
    content => 'modulepath = $basemodulepath',
  }

  service { 'pe-bootstrap':
    ensure  => running,
    require => File['/etc/init.d/pe-bootstrap'],
  }
  service { 'iptables':
    ensure => stopped,
  }
}
