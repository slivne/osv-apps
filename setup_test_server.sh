#!/bin/sh 
#  Copyright (C) 2013 Cloudius Systems, Ltd.

cd ..
sudo ln -s /etc/system-release /etc/fedora-release
sudo scripts/setup.py --test --ec2

sudo echo "[s3tools]" > /etc/yum.repos.d
sudo echo "name=Tools for managing Amazon S3 - Simple Storage Service (RHEL_6)" >> /etc/yum.repos.d
sudo echo "type=rpm-md" >> /etc/yum.repos.d
sudo echo "baseurl=http://s3tools.org/repo/RHEL_6/" >> /etc/yum.repos.d
sudo echo "gpgcheck=1" >> /etc/yum.repos.d
sudo echo "gpgkey=http://s3tools.org/repo/RHEL_6/repodata/repomd.xml.key" >> /etc/yum.repos.d
sudo echo "enabled=1" >> /etc/yum.repos.d

sudo yum install s3cmd
cat s3cfg |sed "s/access_key = XXX/access_key = $AWS_ACCESS_KEY_ID/" | sed "s/secret_key = XXX/secret_key = $AWS_SECRET_ACCESS_KEY/" >  ~/.s3cfg
cd ~/osv/apps/$TEST_APP/tests
./install.sh

  