#!/bin/bash

echo "setting up pe repo"
cp ../files/pe_repo.repo /etc/yum.repos.d/

echo "installing pe-puppet-server package"

yum install -y pe-puppet-server

echo "installing needed module"

/opt/puppet/bin/puppet module install puppetlabs/inifile

echo "running puppet apply to start pe-bootstrap service"

/opt/puppet/bin/puppet apply --modulepath=../../:/etc/puppetlabs/puppet/modules ../tests/init.pp

echo "pe-bootstrap service is now configured, place output of createfiles.rb in /etc/puppetlabs/puppet/data/pe/"
