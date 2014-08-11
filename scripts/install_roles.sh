#!/bin/bash

echo "time is important"
ntpdate -u us.pool.ntp.org

#install pe package repo
echo "installing PE Package repo"
cd /etc/yum.repos.d/

curl -O https://raw.githubusercontent.com/mrzarquon/tinypuppet/master/files/pe_repo.repo

#install puppet
echo "installing puppet agent"
yum install -y pe-agent

# set environment to pe
echo "set agent environment to pe"
/opt/puppet/bin/puppet config set environment pe --section agent

#puppet agent run, wait for cert
echo "running puppet agent to configure services, use pe_bootstrap env"
/opt/puppet/bin/puppet agent --onetime --no-daemonize \
  --ssldir /etc/puppetlabs/puppet/ssl \
  --verbose \
  --waitforcert 10 \
  --certname $(hostname -f) \
  --environment pe_bootstrap \
  --server ca.er.puppetlabs.demo
