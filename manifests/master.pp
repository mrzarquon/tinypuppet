class tinypuppet::master (
  $ca_certname = $::fqdn,
  $dns_alt_names = "puppet,${::fqdn}",
) {

  Ini_setting {
    path   => '/etc/puppetlabs/puppet/puppet.conf',
    ensure => present,
    notify => Service['pe-bootstrap'],
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
  ini_setting { 'environmentpath':
    section => 'main',
    setting => 'environmentpath',
    value   => '$confdir/environments',
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

  #hiera configuration

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure => file,
    source => 'puppet:///modules/tinypuppet/hiera.yaml',
  }
  file { '/etc/puppetlabs/puppet/data':
    ensure => directory,
  }
  file { '/etc/puppetlabs/puppet/data/pe/':
    ensure => directory,
  }
  file { '/etc/puppetlabs/puppet/data/pe_bootstrap':
    ensure  => link,
    target  => '/etc/puppetlabs/puppet/data/pe',
  }



  # environments configuration
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
    content => "modulepath = /etc/puppetlabs/puppet/environments/pe/modules:\$basemodulepath\n",
  }
  file { '/etc/puppetlabs/puppet/environments/pe/manifests/hiera_include.pp':
    ensure  => file,
    content => "hiera_include('bootstrap::classes')",
  }
  file { '/etc/puppetlabs/puppet/environments/pe_bootstrap/manifests/hiera_include.pp':
    ensure  => file,
    content => "hiera_include('bootstrap::classes')",
  }
  file { '/etc/puppetlabs/puppet/environments/pe':
    ensure => directory,
  }
  file { '/etc/puppetlabs/puppet/environments/pe/manifests':
    ensure => directory,
  }
  file { '/etc/puppetlabs/puppet/environments/pe/modules':
    ensure => directory,
  }
  file { '/etc/puppetlabs/puppet/environments/pe/environment.conf':
    ensure  => file,
    content => 'modulepath = ./modules:/opt/puppet/share/puppet/modules\n',
  }
  
  service { 'pe-bootstrap':
    ensure  => running,
    enable  => false,
    require => File['/etc/init.d/pe-bootstrap'],
  }
  service { 'iptables':
    ensure => stopped,
  }
}
