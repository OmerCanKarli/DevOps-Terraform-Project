terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}


data "aws_db_instance" "rds_hostname" {
  tags = {
    Name = "rds_instance"                                          # Burası
  }
}

data "aws_lb" "alb_endpoint" {
  tags = {
    Name = "my_ALB"                                                # Burası
  }
}


resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 10
  db_name              = "phonebook"
  engine               = "mysql"
  engine_version       = "8.0.19"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "omercan99"
  vpc_security_group_ids = [ aws_security_group.rds_SG.id ]
  tags = {
    Name = "rds_instance"
  }

}

resource "aws_lb" "my_ALB" {
  name               = "my_ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_SG.id]
  subnets            = ["subnet-05f3fef3fb9f96560","subnet-003eae3ec5cfe0980","subnet-056cee08b249dcd60","subnet-0cc7533be6a0c42fb","subnet-013ab179c2aa89ff3","subnet-0d3fb4b807d5092bb"]  # Hata Olabilir
  tags = {
    Name = "my_ALB"
  }
}

resource "aws_autoscaling_group" "ec2_ASG" {
  name                      = "ec2_ASG"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = ["subnet-05f3fef3fb9f96560","subnet-003eae3ec5cfe0980","subnet-056cee08b249dcd60","subnet-0cc7533be6a0c42fb","subnet-013ab179c2aa89ff3","subnet-0d3fb4b807d5092bb"]   # Hata Olabilir
  target_group_arns = [ aws_lb_target_group.ec2_TG.arn ]
  launch_template {
    id = aws_launch_template.ec2_LT.id
  }
  
}

resource "aws_lb_target_group" "ec2_TG" {
  name     = "ec2_TG"
  port     = 80
  protocol = "HTTP"
  tags = {
    Name = "ec2_TG"
  }
}

resource "aws_launch_template" "ec2_LT" {
  
  name = "ec2_LT"
  image_id = "ami-079db87dc4c10ac91"                                                        
  instance_type = "t2.micro"
  key_name = "firstkey"
  vpc_security_group_ids = [aws_security_group.ec2_SG.id]                                                                  
  tags = {
      Name = "test"
  }
  user_data = templatefile("${abspath(path.module)}/userdata.sh",{DB_HOSTNAME = data.aws_db_instance.address})                                                                         #    user data en son yapılacak.
}


resource "aws_security_group" "ec2_SG" {
  name        = "ec2_sec_grp"
  description = "EC2 security group which allows HTTP (80) connections only from the security group of Application Load Balancer."

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [ aws_security_group.alb_SG.id ]                                                        
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]                                                      
  }  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_SG"
  }
}




resource "aws_security_group" "alb_SG" {                                                            
  name        = "alb_SG"
  description = "ALB security group which allows HTTP (80) connections from anywhere."

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"                                                                                         
    cidr_blocks      = ["0.0.0.0/0"]
  }
                                                                                                                    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_SG"
  }
}



resource "aws_security_group" "rds_SG" {                                                            
  name        = "rds_SG"
  description = "RDS security group which allows 3306 port connections from anywhere."

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"                                                                                         
    cidr_blocks      = ["0.0.0.0/0"]
  }
                                                                                                                    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_SG"
  }
}


output "connection_url" {
  value = data.aws_lb.alb_endpoint.dns_name
}