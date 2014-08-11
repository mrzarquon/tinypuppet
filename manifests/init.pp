class tinypuppet (
  $ca_certname   = $::fqdn,
  $dns_alt_names = "puppet,${::fqdn}",
) {

  include tinypuppet::prep

  class { 'tinypuppet::master':
    ca_certname   => $ca_certname,
    dns_alt_names => $dns_alt_names,
  }

  class { 'tinypuppet::puppetdb':
    ca_certname => $ca_certname,
  }

}
