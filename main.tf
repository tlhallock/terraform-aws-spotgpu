# ----------------------------------------#
#
#       | Terraform Main file |
#
# ----------------------------------------#
# File: main.tf
# Author: Vithursan Thangarasa (vithursant)
# ----------------------------------------#

# AWS Provider
provider "aws" {
    region = "${var.my_region}"
}

locals {
  avail_zone = "${var.avail_zone}"
}


#data "aws_ami" "al2" {
#  most_recent = true

#  filter {
#    name   = "name"
#    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
#  }

#  owners = ["amazon"]
#}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "key-${uuid()}"
  public_key = "${tls_private_key.key.public_key_openssh}"
}

resource "local_file" "pem" {
  filename        = "${aws_key_pair.generated_key.key_name}.pem"
  content         = "${tls_private_key.key.private_key_pem}"
  file_permission = "400"
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "${var.my_cidr_block}"
    instance_tenancy = "default"
    enable_dns_hostnames = true

    tags = {
        Name = "main_vpc"
    }
}

resource "aws_internet_gateway" "main_vpc_igw" {
    vpc_id = "${aws_vpc.main_vpc.id}"

    tags = {
        Name = "main_vpc_igw"
    }
}

resource "aws_default_route_table" "main_vpc_default_route_table" {
    default_route_table_id = "${aws_vpc.main_vpc.default_route_table_id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main_vpc_igw.id}"
    }

    tags = {
        Name = "main_vpc_default_route_table"
    }
}

resource "aws_subnet" "main_vpc_subnet" {
    vpc_id = "${aws_vpc.main_vpc.id}"
    cidr_block = "${var.my_cidr_block}"
    map_public_ip_on_launch = true
    availability_zone  = "${local.avail_zone}"

    tags = {
        Name = "main_vpc_subnet"
    }
}

resource "aws_default_network_acl" "main_vpc_nacl" {
    default_network_acl_id = "${aws_vpc.main_vpc.default_network_acl_id}"
    subnet_ids = ["${aws_subnet.main_vpc_subnet.id}"]

    ingress {
        protocol   = -1
        rule_no    = 1
        action     = "allow"
//        cidr_block = "${var.my_ip}"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }

    egress {
        protocol   = -1
        rule_no    = 2
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }

    tags = {
        Name = "main_vpc_nacl"
    }
}

resource "aws_default_security_group" "main_vpc_security_group" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "main_vpc_security_group"
    }
}

# SSH access from anywhere
resource "aws_security_group_rule" "ssh_access" {
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_default_security_group.main_vpc_security_group.id
}

# for Jupyter notebook
resource "aws_security_group_rule" "jupyter_access" {
    type        = "ingress"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_default_security_group.main_vpc_security_group.id
}

# for git clone
resource "aws_security_group_rule" "git_clone" {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_default_security_group.main_vpc_security_group.id
}

# resource "aws_spot_instance_request" "aws_dl_custom_spot" {
resource "aws_instance" "aws_dl_custom_spot" {
    ami                         = "${var.ami_id}"
#    spot_price                  = "${var.spot_price}"
    instance_type               = "${var.instance_type}"
  user_data              = "${file("script.sh")}"
    key_name               = "${aws_key_pair.generated_key.key_name}"
    monitoring                  = true
    associate_public_ip_address = true
    security_groups             = ["${aws_default_security_group.main_vpc_security_group.id}"]
    subnet_id                   = "${aws_subnet.main_vpc_subnet.id}"
    tags = {
        Name = "aws_dl_custom_spot"
    }
}

########################################################
# OLD:
#resource "aws_instance" "aws_dl_custom_spot" {
#    ami                         = "${var.ami_id}"
#  availability_zone      = "${var.availability_zone}"
#  instance_type          = "${var.instance_type}"
#  key_name               = "${aws_key_pair.generated_key.key_name}"
#  vpc_security_group_ids = ["${aws_security_group.jupyter.id}"]
#  user_data              = "${file("script.sh")}"
#}
########################################################






resource "aws_ebs_volume" "jupyter" {
  availability_zone = "${var.avail_zone}"
  size              = "${var.ebs_volume_size}"
  type              = "gp2"

#  tags = {
#    Name        = "${title(var.service)}-${timestamp()}_Anaconda3"
#    Service     = "${var.service}"
#    Contact     = "${var.contact}"
#    Environment = "${title(lower(var.environment))}"
#    Terraform   = "true"
#  }
}

resource "aws_volume_attachment" "jupyter" {
  device_name  = "/dev/sdh"
#  instance_id  = "${aws_spot_instance_request.aws_dl_custom_spot.id}"
  instance_id  = "${aws_instance.aws_dl_custom_spot.id}"
  volume_id    = "${aws_ebs_volume.jupyter.id}"
  force_detach = true
}
