#!/bin/bash
yum update -y
yum install python3 -y
yum install python-pip -y
pip3 install Flask==2.3.3
pip3 install Flask-MySql
yum install git -y
export MYSQL_DATABASE_HOST=${db_hostname}
TOKEN=${git_token}
NAME=${git_name}
cd /home/ec2-user
git clone https://$TOKEN@github.com/$NAME/DevOps-Terraform-Project.git
python3 /home/ec2-user/DevOps-Terraform-Project/phonebook-app.py