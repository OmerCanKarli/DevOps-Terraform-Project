data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "selected_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "aws_lb" "alb_endpoint" {
  depends_on = [aws_lb.my_ALB]
  tags = {
    Name = "my_ALB" # Burası
  }
}

data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

data "aws_route53_zone" "selected" {
  name = var.hosted-zone
}