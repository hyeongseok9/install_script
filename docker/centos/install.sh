#!/bin/bash


yum remove docker docker-common docker-selinux docker-engine < /dev/null

sudo yum install -y yum-utils \
	  device-mapper-persistent-data \
	    lvm2 < /dev/null
  
sudo yum-config-manager \
	    --add-repo \
	        https://download.docker.com/linux/centos/docker-ce.repo < /dev/null
yum-config-manager --enable docker-ce-edge < /dev/null
yum-config-manager --enable docker-ce-test < /dev/null
yum install -y docker-ce < /dev/null
