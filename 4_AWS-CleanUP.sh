
#!/bin/bash

set -e

#-----Removes all demo resources-------------------------------------

REGION = '< my AWS region >' # for Australia use 'ap-southeast-2'
ACCOUNT = '< my AWS account number >'

# Delete Redshift, Matillion and Yellowfin rules into the main ndc security group - TO:'unauthorize'
SECURITYGROUPID=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 5439 --cidr 10.0.0.0/16

# Release the elasticips for Matillion and Yellowfin
aws ec2 release-address --allocation-id <value1>
aws ec2 release-address --allocation-id <value2>

# Delete the Matillion, Yellowfin EC2 instances - dissassociates elassticip automatically
aws ec2 describe-instances --resources ami-<value> i-<value> --tags Key=show,Value=ndc --region $REGION
aws ec2 terminate-instances ....

# Delete the Redshift cluster tagged instances and delete them
aws redshift describe-instances --resources ami-<value> i-<value> --tags Key=show,Value=ndc
aws redshift delete-cluster ....

# Delete the redshift security group
# Remove the security (ingress) rules in the ndc security group
aws redshift delete-cluster-subnet-group ...
aws redshift delete-cluster-security-group ...

# Delete the subnets 
SUBNETID1=`aws ec2 describe-subnets --region $REGION`
SUBNETID2=`aws ec2 describe-subnets --region $REGION`
aws ec2 delete-subnet --subnet-id $SUBNETID1
aws ec2 delete-subnet --subnet-id $SUBNETID2

# Delete the VPC (deletes the route table, internet gateway and subnets)
VPCID=`aws ec2 describe-vpcs --region $REGION`
aws ec2 delete-vpc --vpc-id $VPCID

# Delete non-empty public S3 data bucket
aws s3 rb s3://<bucketName> <tag>.... --force

# Delete the IAM user, role and policy
aws iam delete-user --user-name 'WAREHOUSEUSER'
aws iam delete-role --role-name 'WAREHOUSEROLE'
aws iam delete-policy --policy-arn 'arn:aws:iam::$ACCOUNT:policy/WAREHOUSEPOLICY'

