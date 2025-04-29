variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "demo_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  type = map(number)
  default = {
    "private_subnet_1" = 1
  }
}

variable "public_subnets" {
  type = map(number)
  default = {
    "public_subnet_1" = 1
  }
}

variable "instance_name" {
  type = string
}

variable "my_ami" {
  type    = string
  default = "ami-04b4f1a9cf54c11d0"
}

/*
variable "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the private SSH key"
  type        = string
}
*/