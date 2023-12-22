resource "aws_security_group" "ec2_SG" {
  name        = "ec2-SG"
  description = "EC2 security group which allows HTTP (80) connections only from the security group of Application Load Balancer."
  vpc_id      = data.aws_vpc.default_vpc.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_SG.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_SG"
  }
}

resource "aws_security_group" "alb_SG" {
  name        = "alb-SG"
  description = "ALB security group which allows HTTP (80) connections from anywhere."
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_SG"
  }
}

resource "aws_security_group" "rds_SG" {
  name        = "rds-SG"
  vpc_id      = data.aws_vpc.default_vpc.id
  description = "RDS security group which allows 3306 port connections from anywhere."

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_SG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_SG"
  }
}