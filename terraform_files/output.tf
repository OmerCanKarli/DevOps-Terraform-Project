output "alb_dns_name" {
  value = "http://${aws_lb.my_ALB.dns_name}"
}

output "websiteurl" {
  value = "http://${aws_route53_record.phonebook.name}"
}

output "db-endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

output "db-address" {
  value = aws_db_instance.rds_instance.address
}