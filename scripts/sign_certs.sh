#!/bin/bash

while true;
do
  /opt/puppet/bin/puppet cert sign --all --allow-dns-alt-names
  sleep 5
done

