#!/bin/bash

yum install python3.12-devel python3.12-pip -y | tee -a /opt/userdata.log
pip3.12 install ansible ansible-core==2.16 botocore boto3 | tee -a /opt/userdata.log
ansible-pull -i localhost, -U https://github.com/kp3073/Expense-ansible main.yml -e role_name=${role_name} -e env=${env} | tee -a /opt/userdata.log