#!/bin/bash -x
if [ -f /tmp/boot ]; then
  echo "already Run"
  exit 0
fi
set -e
echo start >> /tmp/boot
echo "installing wget gcc $(uptime)" >> /tmp/boot 
yum update -y
yum install -y git

sudo -i -u ec2-user -H sh -c "echo 'Host github.com' >> ~/.ssh/config; echo '   StrictHostKeyChecking no' >> ~/.ssh/config"
sudo -i -u ec2-user -H sh -c "cd ~/; git clone https://github.com/cloudius-systems/osv.git ; cd osv ; git submodule update --init --recursive"
sudo -i -u ec2-user -H sh -c "cd ~/osv/apps; git remote add shlomi https://github.com/slivne/osv-apps.git; git fetch shlomi; git checkout shlomi/master; cp *.sh ../scripts; cp *.py ../scripts/"
   
cd /home/ec2-user/osv
ln -s /etc/system-release /etc/fedora-release
./scripts/setup.py --test --ec2
echo "Setup done $(uptime)" >> /tmp/boot

echo '[s3tools]' > /etc/yum.repos.d/s3tools.repo
echo 'name=Tools for managing Amazon S3 - Simple Storage Service (RHEL_6)' >> /etc/yum.repos.d/s3tools.repo
echo 'type=rpm-md' >> /etc/yum.repos.d/s3tools.repo
echo 'baseurl=http://s3tools.org/repo/RHEL_6/' >> /etc/yum.repos.d/s3tools.repo
echo 'gpgcheck=1' >> /etc/yum.repos.d/s3tools.repo
echo 'gpgkey=http://s3tools.org/repo/RHEL_6/repodata/repomd.xml.key' >> /etc/yum.repos.d/s3tools.repo
echo 'enabled=1' >> /etc/yum.repos.d/s3tools.repo

yum install -y s3cmd

echo "Installed s3tools $(uptime)" >> /tmp/boot
sudo -i -u ec2-user -H sh -c "echo 'export AWS_ACCESS_KEY_ID=$$aws_keys' >> ~/.bashrc"
sudo -i -u ec2-user -H sh -c "echo 'export AWS_ACCESS_KEY=\$AWS_ACCESS_KEY_ID' >> ~/.bashrc"
sudo -i -u ec2-user -H sh -c "echo 'export AWS_SECRET_ACCESS_KEY=$$aws_secret' >> ~/.bashrc"
sudo -i -u ec2-user -H sh -c "echo 'export AWS_SECRET_KEY=\$AWS_SECRET_ACCESS_KEY' >> ~/.bashrc"
  
sudo -i -u ec2-user -H sh -c "echo 'export TEST_APP=$$test_name' >> ~/.bashrc"
sudo -i -u ec2-user -H sh -c 'cd ~/osv/apps; cat s3cfg |sed "s/access_key = XXX/access_key = $AWS_ACCESS_KEY_ID/" | sed "s/secret_key = XXX/secret_key = $AWS_SECRET_ACCESS_KEY/" >  ~/.s3cfg'


sudo -i -u ec2-user -H sh -c "cd ~/osv/apps/; testup_test_server.sh"

echo "Done $(uptime)" >> /tmp/boot


