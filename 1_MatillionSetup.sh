#!/bin/bash

set -e

#------Sets up Matillion ETL on AWS EC2)-------------------------

REGION = '< my AWS region >' # for Australia use 'ap-southeast-2'
MYKEYPAIR = '< my keypair >' 

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
IPALLOCATIONID=`aws ec2 allocate-address --domain vpc --region $REGION`
AMIMATILLION = 'ami-817e56e2' #for Australia region, get your value from AWS Marketplace Matillion page

#  Create a security group for Matillion EC2 instance and set inbound rules
SECURITYGROUPIDMT=`aws ec2 create-security-group --group-name NDC-matillion --vpc-id $VPCID`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPIDMT  --protocol tcp --port 22 --cidr <myIPAddress>
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPIDMT  --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPIDMT  --protocol tcp --port 443 --cidr 0.0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPIDMT  --protocol tcp --port 3000 --cidr 10.0.0.0/16

# Create an instance of Matillion from the AWS Marketplace AMI for your region
INSTANCEID=`aws ec2 run-instances --image-id $AMIMATILLION --count 1 --instance-type m3.large \
    --key-name $MYKEYPAIR --security-group-ids $SECURITYGROUPIDMT --subnet-id $SUBNETID`

# Associate an elastic IP with your Redshift instance        
aws ec2 associate-address --instance-id $INSTANCEID --allocation-id $IPALLOCATIONID

# Connect to the instance with a browser using the EC2 instance public IP, 'http://<publicIP'
# Log in with the username 'ec2-user' and password of your EC2 INSTANCEID i-xxxxxxxx (e.g. i-58244af7)
# Fill in the Manage Credentials to connect to your Amazon Redshift environment  
# Use the test button to ensure connectivity to Redshift before continuing
# TIP: If you can't connect, verify your security group inbound/outbound rules'
# NOTE: Administer your instance of Matillion at 'http://<publicIP>/admin' to manage users and other configuration

# Try out the sample packages, 'dim_airport_setup' and'dim_airpots' -- they populate from public S3 buckets

# (Optional) Load Data into Redshift via Matillion using data in public S3 bucket

# Resources
# IAM permissions needed -- https://redshiftsupport.matillion.com/customer/en/portal/articles/2054760-managing-credentials?b_id=8915
# Security warning - https://redshiftsupport.matillion.com/customer/portal/articles/2236864-publicly-available-warning
