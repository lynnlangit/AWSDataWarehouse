
#!/bin/bash

set -e

#-----Sets up Redshift on AWS EC2-------------------------------------

REGION = '< my AWS region >' # for Australia use 'ap-southeast-2'
MYKEYPAIR = '< my keypair >'

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID1=`aws ec2 describe-subnet --cidr-block 10.0.0.0/28 --region $REGION`
SUBNETID2=`aws ec2 describe-subnet --cidr-block 10.0.0.16/28 --region $REGION`
ROUTETABLEID=`aws ec2 describe-route-tables --region $REGION`

#  Create an EC2 security group for Redshift instance and set inbound rules
SECURITYGROUPIDRS=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPIDRS  --protocol tcp --port 5439 --cidr 10.0.0.0/16

#  Create an RDS subnet group for Redshift instance 
SUBNETGROUP = 'aws redshift create-cluster-subnet-group --cluster-subnet-group-name "ndcdemo" \
    --description "ndcdmo" --subnet-ids $SUBNETID $SUBNETID2'

#  Create an RDS security group for Redshift instance 
REDSHIFTSECURITYGROUP='aws redshift create-cluster-security-group --cluster-security-group-name "ndcdemo"'

# Create an instance of Redshift for your region
REDSHIFTID =`aws redshift create-cluster --cluster-identifier ndcdemo --node-type dc1.large \
    --master-username admin --master-user-password Password1 \
    --cluster-type single-node --db-name ndc --cluster-subnet-group-name $SUBNETGROUP`
    




