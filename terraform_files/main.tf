resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  db_name                = "phonebook"
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "omercan99"
  port                   = 3306
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_SG.id]
  tags = {
    Name = "rds_instance"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_TG.arn
  }
}

resource "aws_lb" "my_ALB" {
  name               = "my-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_SG.id]
  subnets            = data.aws_subnets.selected_subnets.ids
  tags = {
    Name = "my_ALB"
  }
}

resource "aws_autoscaling_group" "ec2_ASG" {
  name                      = "ec2-ASG"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 500
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = data.aws_subnets.selected_subnets.ids
  target_group_arns         = [aws_lb_target_group.ec2_TG.arn]
  launch_template {
    id = aws_launch_template.ec2_LT.id
  }

}

resource "aws_lb_target_group" "ec2_TG" {
  name     = "ec2-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  tags = {
    Name = "ec2_TG"
  }
}

resource "aws_launch_template" "ec2_LT" {
  name                   = "ec2-LT"
  image_id               = data.aws_ami.ec2_ami.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_SG.id]
  user_data              = base64encode(templatefile("${abspath(path.module)}/userdata.sh", { db_hostname = aws_db_instance.rds_instance.address, git_token = var.git-token, git_name = var.git-name }))
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web Server of Phonebook App"
    }
  }
}


resource "aws_route53_record" "phonebook" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "phonebook.${var.hosted-zone}"
  type    = "A"

  alias {
    name                   = aws_lb.my_ALB.dns_name
    zone_id                = aws_lb.my_ALB.zone_id
    evaluate_target_health = true
  }
} 