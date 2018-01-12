#!/bin/bash

sudo yum install -y centos-release-scl
sudo yum install -y {python_version}

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y ${docker_version}

sudo yum install -y python-pip

#docker-py is a dependency for ansible deployment
sudo pip install docker

#wait to mount EBS vol
sleep 2m

sudo mkfs -t ext4 ${ebs_device_name}

sudo mkdir ${mount_point}

sudo mount ${ebs_device_name} ${mount_point}

