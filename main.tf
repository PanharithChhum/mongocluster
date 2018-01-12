#ec2 module and security group module 

# Specify the provider and access details
provider "aws" {
    region                      = "${var.aws_region}"
    access_key                  = "${var.aws_access_key}"
    secret_key                  = "${var.aws_secret_key}"
}

# Allow port 27017 for mongo 
# Added mongo-tcp ingress_rule to security group module
module "security_group" {
    source                      = "./terraform/security-group"
    name                        = "mongo-cluster-security-group"
    description                 = "mongo-cluster-security-group"
    vpc_id                      = "${var.vpc_id}"
    ingress_cidr_blocks         = ["0.0.0.0/0"]
    ingress_rules               = ["mongo-tcp", "ssh-tcp", "all-icmp"]
    egress_rules                = ["all-all"]
}

data template_file "template_file" {
    template                    = "${var.user_data}"
    vars    {
        python_version  = "${var.python_version}"
        docker_version  = "${var.docker_version}"
        ebs_device_name = "${var.ebs_device_name}"
        mount_point     = "${var.mount_point}"
    }
}


#added multi-subnet compatability to ec2 module
module "ec2" {
    source                      = "./terraform/ec2-instance"
    name                        = "${var.name}"
    ami                         = "${var.ami}"
    count                       = "${var.count}"
    instance_type               = "${var.instance_type}"
    subnet_id                   = "${var.subnets}"
    key_name                    = "${var.key_name}"
    vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
    associate_public_ip_address = true
    tags = {
        ansibleGroup    = "${var.ansibleGroup}"
    }
}

resource "aws_ebs_volume" "volumes" {
    availability_zone           = "${element(var.availability_zones, count.index)}"
    size                        = "${var.ebs_volume_size}"
    count                       = "${var.count}"
}

resource "aws_volume_attachment" "ebs_attachment" {
    count                       = "${var.count}"
    device_name                 = "/dev/sdh"
    volume_id                   = "${element(aws_ebs_volume.volumes.*.id, count.index)}"
    instance_id                 = "${element(module.ec2.id, count.index)}"
}

resource "aws_route53_record" "route53_record" {
    count                       = "${var.count}"
    zone_id                     = "${var.zone_id}"
    name                        = "mongo-${count.index}.${var.domain_name}"
    type                        = "A"
    ttl                         = "${var.ttl}"
    records                     = ["${element(module.ec2.public_ip, count.index)}"]
}

