#!/bin/bash
# 本スクリプトはterraformでのシステム作成後に実行

echo ">attach iam role to cloud9 instance"
aws ec2 associate-iam-instance-profile --instance-id $(terraform output cloud9-instance-id | tr -d '"') --iam-instance-profile Name=$(terraform output sbcntr-cloud9-role-name)
