# ----------------------------------------#
#
#       | Terraform Variables file |
#
# ----------------------------------------#
# File: variables.tf
# Author: Vithursan Thangarasa (vithursant)
# ----------------------------------------#

variable "my_region" {
  type    = string
  default = "us-west-1"
  description = "The AWS region to deploy into (i.e. us-east-1)"
}

variable "avail_zone" {
  type    = string
  default = "us-west-1a"
  description = "The AWS availability zone location within the selected region (i.e. us-east-2a)."
}

variable "my_ip" {
  type    = string
  default = "161.69.22.122/32"
}

variable "my_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

# variable "my_key_pair_name" {
#  type    = string
#  default = "vi-test"
#  description = "The name of the SSH key to install onto the instances."
#}

#variable "ssh-key-dir" {
#  default     = "~/.ssh/"
#  description = "The path to SSH keys - include ending '/'"
#}

variable "instance_type" {
  type    = string

  # https://aws.amazon.com/ec2/instance-types/
  # $98.32    p5.48xlarge : 192 cpus, 8 gpus with 640 gpu memory
  # $32.7726  p4d.24xlarge	8 gpus
  # $3.06     p3.2xlarge    1 gpu, 8cpu, 61gb memory, 16gb gpu memory
  # $1.006    g5.xlarge     1 gpu, 24 gb gpu memory, 16gb memory
  # $0.526    g4dn.xlarge   1 gpu,	4 cpu,	16gb memory, 16gb gpu memory

  #default = "g5.xlarge"
  default = "t2.micro"
  description = "The instance type to provision the instances from (i.e. p2.xlarge)."
}

variable "spot_price" {
  type    = string
  default = "1.00"
  description = "The maximum hourly price (bid) you are willing to pay for the specified instance, i.e. 0.10. This price should not be below AWS' minimum spot price for the instance based on the region."
}

variable "ebs_volume_size" {
  type    = string
  default = "1"
  description = "The Amazon EBS volume size (1 GB - 16 TB)."
}

variable "ami_id" {
  type    = string
  # Default AWS Deep Learning AMI (Ubuntu)
  # Supported EC2 instances: P5, P4d, P4de, P3, P3dn, G5, G4dn, G3. Release notes:
  # https://aws.amazon.com/ec2/instance-types/
  # $98.32    p5.48xlarge : 192 cpus, 8 gpus with 640 gpu memory
  # $32.7726  p4d.24xlarge	8 gpus
  # $3.06     p3.2xlarge    1 gpu, 8cpu, 61gb memory, 16gb gpu memory
  # $1.006    g5.xlarge     1 gpu, 24 gb gpu memory, 16gb memory
  # $0.526    g4dn.xlarge   1 gpu,	4 cpu,	16gb memory, 16gb gpu memory
  default = "ami-0bfb2ef7f314185e4"
  description = "The AMI ID to use for each instance. The AMI ID will be different depending on the region, even though the name is the same."
}

#variable "num_instances" {
#  type    = string
#  default = "1"
#  description = "The number of AWS EC2 instances to provision."
#}
