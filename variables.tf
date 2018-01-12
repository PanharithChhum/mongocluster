
# AWS info
variable "aws_region" {
    default     = "us-east-1"
    description = "AWS region"
}

variable "aws_access_key" {
     description = "AWS access key"
}

variable "aws_secret_key" {
     description = "AWS secret key"
}

# mongo-cluster security group
variable "vpc_id" {
    default     = "vpc-123456789"
    description = "The VPC where for the mongo-cluster deployment"
}

# user data
variable "user_data" {
    default     = "user_data.tpl"
    description = "user data to bootsrap ec2 instance"
}

variable "python_version" {
    default     = "python27"
    description = "python version to install on ec2 instance (useful for ansible)"
}

variable "docker_version" {
    default     = "docker-ce-17.06.1.ce"
    description = "docker version to install on ec2 instance"
}

variable "ebs_device_name" {
    default     = "/dev/xvdh"
    description = "device name for ebs volume"
}

variable "mount_point" {
    default     = "/data"
    description = "mount mongo data into persistent volume"
}

# mongo-cluster ec2 instances
variable "name" {
    default     = "mongo-cluster"
    description = "Name of mongo-cluster"
}

variable "ami" {
    default     = "ami-123456789"
    description = "ami for ec2 instance"
}

variable "count" {
    default     = 3
    description = "number of nodes in the cluster"
}

variable "instance_type" {
    description = "instance type and size for mongo cluster"
}

# SUBNETS ORDER MUST MATCH AVAILABILITY ZONES ORDER
variable "subnets" {
    type        = "list"
    default     = ["subnet-123", "subnet-456", "subnet-789"]
    description = "subnets for multi-AZ cluster"
}

variable "key_name" {
    description = "private key to use"
}

#Camel case is better for ec2.py
variable "ansibleGroup" {
    default     = "mongoCluster"
    description = "the tag based group that ec2.py will use"
}

variable "availability_zones" {
    default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
    description = "list of availability zones for EBS volumes"
    type        = "list"
}

variable "ebs_volume_size" {
    default     = 1000
    description = "size in gb of ebs volumes"
}

variable "domain_name" {
    default     = "test.com"
    description = "domain name for DNS entries"
}

variable "ttl" {
    default     = 300
    description = "ttl of DNS a record entries"
}

variable "zone_id" {
    description = "Route53 DNS zone id"
}


