# this is a prep class to automate downloading and installing
# needed modules for the master

class tinypuppet::prep (
  $pe_install_version = '3.3.0',
  $pe_er_version = '1.0.0',
  $pe_build_type = 'el-6-x86_64',
) {

  $s3_pe_base = 'https://s3.amazonaws.com/pe-builds/released'
  $s3_er_base = 'https://prosvcs.s3.amazonaws.com/prosvcs-er'
  $pe_folder = "puppet-enterprise-${pe_install_version}-${pe_build_type}"
  $pe_tgz = "${pe_folder}.tar.gz"
  $er_folder = "prosvcs-er-${pe_er_version}"
  $er_tgz = "${er_folder}.tar.gz"
  $s3_pe_url = "${s3_pe_base}/${pe_install_version}/${pe_tgz}"
  $s3_er_url = "${s3_er_base}/${er_tgz}"
  $pmt_force = '/opt/puppet/bin/puppet module install --ignore-dependencies'
  $pmt_modulepath = '/opt/puppet/share/puppet/modules'

  file { '/opt/pe_staging':
    ensure => directory,
  }

  exec { 'retrieve-installer':
    command => "/usr/bin/curl -O ${s3_pe_url}",
    cwd     => '/opt/pe_staging',
    creates => "/opt/pe_staging/${pe_tgz}",
    timeout => 1500,
    require => File['/opt/pe_staging'],
  }
  exec { 'unpack-installer':
    command => "/bin/tar -xzf ${pe_tgz}",
    cwd     => '/opt/pe_staging',
    creates => "/opt/pe_staging/${pe_folder}",
    timeout => 1500,
    require => File['/opt/pe_staging'],
  }

  exec { 'retrieve-er':
    command => "/usr/bin/curl -O ${s3_er_url}",
    cwd     => '/opt/pe_staging',
    creates => "/opt/pe_staging/${er_tgz}",
    timeout => 1500,
    require => File['/opt/pe_staging'],
  }

  exec { 'unpack-er':
    command => "/bin/tar xzf ${er_tgz}",
    cwd     => '/opt/pe_staging',
    creates => "/opt/pe_staging/${er_folder}",
    require => Exec['retrieve-er'],
  }

  exec { 'install-pe-modules':
    command     => "/bin/find /opt/pe_staging/${pe_folder}/modules/ -name puppetlabs-*.tar.gz -exec ${pmt_force} --modulepath ${pmt_modulepath} {} \\;",
    refreshonly => true,
    subscribe   => Exec['unpack-installer'],
  }

  exec { 'install-er-modules':
    command     => "/bin/cp -r /opt/pe_staging/${er_folder}/modules/* /etc/puppetlabs/puppet/environments/pe/modules/",
    refreshonly => true,
    subscribe   => Exec['unpack-er'],
    require     => File['/etc/puppetlabs/puppet/environments/pe/modules'],
  }

}
