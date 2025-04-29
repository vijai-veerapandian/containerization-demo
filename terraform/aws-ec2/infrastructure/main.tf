# 1 Retrieve the list of AZs in the current AWS region
# 2 Define the VPC
# 3 Define the Security group
# 4 Deploy the private subnets
# 5 Deploy the public subnets
# 6 Define the internet Gateway
# 7 Define the nat gateway
# 8 Define Route table for public subnet
# 9 Define Route table for private subnet
# 10 Associate the Route table with the public and private subnet
# 11 Define SSH Key generation for AWS EC2 instance
# 12 Deploy AWS EC2 instance
# 13 S3 Bucket deploy only if not existing

# 1 Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# 2 Define the VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# 3 Define the Security group
resource "aws_security_group" "demo_sg" {
  name        = "demo_security_group"
  description = "demo security group"
  vpc_id      = aws_vpc.demo_vpc.id

  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "Allow ssh inbound traffic"
  # }

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "Allow http inbound traffic"
  # }

  #   ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "Allow https inbound traffic"
  # }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "Allow all outbound traffic"
  # }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all inbound traffic
    description = "Allow all inbound traffic for testing"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
    description = "Allow all outbound traffic"
  }

  tags = {
    Name      = "demo_security_group"
    Terraform = "true"
  }
}

# 4 Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

# 5 Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

# 6 Define Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo_igw"
  }
}

# 7 Define nat gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "demo_igw_eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id

  tags = {
    Name = "demo_nat_gateway"
  }
}

# 8 Define Route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name      = "demo_public_route_table"
    Terraform = "true"
  }
}

# 9 Define Route table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "demo_private_route_table"
    Terraform = "true"
  }
}

# 10 Associate the Route table with the public and private subnet

resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

# 11 Define SSH Key generation for AWS EC2 instance

resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "ec2awskey.pem"
  file_permission = "0600"
}

resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated" {
  key_name   = "ec2awskey"
  public_key = tls_private_key.generated.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}

resource "null_resource" "set_key_permission" {
  triggers = {
    key_pem = tls_private_key.generated.private_key_pem
  }

  provisioner "local-exec" {
    command = "chmod 600 ec2awskey.pem"
  }
  depends_on = [local_file.private_key_pem]
}

# 12 Deploy AWS EC2 instance

resource "aws_instance" "demo_app" {
  ami                    = var.my_ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnets["public_subnet_1"].id
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  key_name               = aws_key_pair.generated.key_name
  
  tags = {
    Terraform   = "true"
    Name        = var.instance_name
  }
}

# Docker setup using remote-exec provisioner
resource "null_resource" "docker_setup" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.demo_app.public_ip
      user        = "ubuntu"
      private_key = file("ec2awskey.pem")
    }

    inline = [
  "set -e",  # Stop on the first error
  "set -x",  # Print each command before execution
  "sudo apt update",
  "curl -fsSL https://get.docker.com -o get-docker.sh",
  "sudo sh get-docker.sh",
  "sudo systemctl enable docker",
  "sudo systemctl start docker",
  "sudo usermod -aG docker ubuntu",
  "sudo apt-get install docker-compose -y",
  "docker --version",
  "docker-compose --version",
  "sleep 10",
  "sudo docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions",
  "sudo docker plugin ls",
  "sleep 5",
  "git clone --branch testv4 https://github.com/vijai-veerapandian/myweather-app.git /home/ubuntu/app || true",
  "cd /home/ubuntu/app && sudo docker-compose up -d"
    ]
  }

  depends_on = [aws_instance.demo_app]
}

# 13 Backend configuration for S3 and DynamoDB

terraform {
  backend "s3" {
    bucket         = "mytf-state-app-bucket"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = var.aws_region
}