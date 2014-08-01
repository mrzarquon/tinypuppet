#!/bin/bash

declare -x PUPPET="/opt/puppet/bin/puppet"

/etc/init.d/pe-puppet stop

rm -rf /etc/puppetlabs/puppet/ssl

$PUPPET config set certname tinymaster --section main
$PUPPET config set dns_alt_names puppet,tinymaster,puppet.fqdn,tinymaster.fqdn --section main
$PUPPET config set manifest /etc/puppetlabs/puppet/manifests/site.pp --section main
$PUPPET config set server tinymaster --section main
$PUPPET config set reports store --section master

cp pe-puppetmaster /etc/init.d/pe-puppetmaster
chmod +x /etc/init.d/pe-puppetmaster
