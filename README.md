POC TinyPuppet Project

The goal of this is to promote an agent to a temporary webrick master and puppetdb instance (using the in memory database).

This is tested on centos 6

files/pe\_repo.repo is yum repo pointing to a S3 bucket for easy testing of this.

To install:

Copy files/pe\_repo.repo to /etc/yum.repos.d/

yum install pe-agent

puppet apply --modulepath=../ tests/init.pp
