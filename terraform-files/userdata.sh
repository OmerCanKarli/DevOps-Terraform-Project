#! /bin/bash -x
yum update -y
yum install python3 -y
yum install python-pip -y
pip3 install Flask==2.3.3
pip3 install Flask-MySql
pip3 install boto3
yum install git -y
export MYSQL_DATABASE_HOST=${DB_HOSTNAME}
TOKEN="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"
cd /home/ec2-user
git clone https://$TOKEN@github.com/OmerCanKarli/DevOps-Terraform-Project.git
python3 /home/ec2-user/DevOps-Terraform-Project/phonebook-app.py