#!/bin/bash


apt-get remove docker docker-engine docker.io < /dev/null

apt-get update < /dev/null

sudo apt-get install \
	    apt-transport-https \
	        ca-certificates \
		    curl \
		        software-properties-common < /dev/null
	
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88 < /dev/null

add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	      $(lsb_release -cs) \
	         stable" < /dev/null
   
apt-get update    < /dev/null

apt-get install docker-ce < /dev/null
