#!/bin/bash



VPC=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true \
--region us-east-1 | grep vpc-*)


#return default vpc-id
VPCID=$(echo $VPC | sed -e "s/^.*\"\(.*\)\".*$/\1/")
echo $VPCID
SUBNET=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPCID" \
"Name=availabilityZone,Values=us-east-1a" --region us-east-1 | grep SubnetId)

#return default subnet-id
SUBNETID=$(echo $SUBNET | sed -e "s/^.*\"\(.*\)\".*$/\1/")
echo $SUBNETID



aws cloudformation create-stack --stack-name h2o-test2 \
--template-body file://aws/h2o_cluster.yml \
--parameters "ParameterKey=KeyName,ParameterValue=myAws" \
"ParameterKey=InstanceType,ParameterValue=t2.micro" \
"ParameterKey=vmCount,ParameterValue=1" \
"ParameterKey=SSHLocation,ParameterValue=0.0.0.0/0" \
"ParameterKey=VPC,ParameterValue=vpc-3a814d5e" \
"ParameterKey=PublicSubnet,ParameterValue=subnet-8f6d41d6" \
--capabilities CAPABILITY_IAM --tags Key=Name,Value=CLUSTERNAME


#returns instance is of autoscaling group name
AWS_PROFILE=thridpoint aws autoscaling describe-auto-scaling-groups \
--auto-scaling-group-name h2o-return2-H2OFleet-4QB9PXSKY4TB --region us-east-1 \
--query AutoScalingGroups[].Instances[].InstanceId --output text
