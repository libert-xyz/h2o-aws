#!/bin/bash

#MIT License
#Copyright (c) 2017 Libert R Schmidt
#Maintainer: rschmidt@nuvops.com


set -e

#--------------------------------------------------------------------------
# Environment variables you might want to change.
# -----------------------------------------------------------------------

MAX_INSTANCES=15

#key pair must exist in the account
KEY_PAIR='h2o'

#public ip addresses with access to the instances
ALLOWED_NETWORK='0.0.0.0/0'

AWS_REGION='us-east-1'
#Availability Zone
AZ='us-east-1a'

INSTANCE_TYPE='t2.micro'

#AWS CLI PROFILE http://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html
PROFILE='thridpoint'

#--------------------------------------------------------------------------
# No need to change anything below here.
#--------------------------------------------------------------------------

echo
echo "H2O.ai cluster in AWS"
echo


if type "$aws" &> /dev/null; then
  echo "[Error]: aws-cli not installed"
  echo "[Install]: pip install awscli"
  exit 1;
fi

echo -n "Cluster Name: "
read CLUSTER

#check alphanumeric characters and hyphens
if ! [[ "$CLUSTER" =~ ^[a-zA-Z0-9][-a-zA-Z0-9]{1,100}[a-zA-Z0-9]$ ]]; then
  echo "[Error]: A Cluster name can contain only alphanumeric characters and hyphens"
  exit 1;
fi

echo
echo -n "Number of Instances: "
read NODES
if ! [[ "$NODES" =~ ^[0-9]+$ ]]; then
  echo "[Error]: Invalid number"
  exit 1;
elif [ "$NODES" -gt "$MAX_INSTANCES" ]; then
  echo "[Error]: Max num of instances $MAX_INSTANCES"
  exit 1;
fi

echo
echo -n "Is this correct? "
echo
echo
echo "############################"
echo "### Cluster Name: $CLUSTER"
echo "### Number of Instances: $NODES"
echo "############################"
echo
echo -n "[yes or no]: "
read YNO

case $YNO in

        [yY] | [yY][Ee][Ss] )
                echo "Deploying H2O Cluster..."

                #--------------------------------------------------------------------------
                # Gather VPC-id and Subnet-id
                #--------------------------------------------------------------------------

                VPC=$(AWS_PROFILE=$PROFILE aws ec2 describe-vpcs --filters Name=isDefault,Values=true \
                --region $AWS_REGION | grep vpc-*)

                if ! [[ $? -eq 0 ]]; then
                  echo "[Error:] VPC command"
                  exit 1;
                fi

                #return default vpc-id
                VPCID=$(echo $VPC | sed -e "s/^.*\"\(.*\)\".*$/\1/")

                SUBNET=$(AWS_PROFILE=$PROFILE aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPCID" \
                "Name=availabilityZone,Values=$AZ" --region $AWS_REGION | grep SubnetId)

                if ! [[ $? -eq 0 ]]; then
                  echo '[Error:] Subnet command'
                  exit 1;
                fi

                #return default subnet-id
                SUBNETID=$(echo $SUBNET | sed -e "s/^.*\"\(.*\)\".*$/\1/")

                #--------------------------------------------------------------------------
                # Launch CloudFormation
                #--------------------------------------------------------------------------

                LAUNCH=$(AWS_PROFILE=$PROFILE aws cloudformation create-stack --stack-name $CLUSTER \
                --template-body file://aws/h2o_cluster.yml \
                --parameters "ParameterKey=KeyName,ParameterValue=$KEY_PAIR" \
                "ParameterKey=InstanceType,ParameterValue=$INSTANCE_TYPE" \
                "ParameterKey=vmCount,ParameterValue=$NODES" \
                "ParameterKey=SSHLocation,ParameterValue=$ALLOWED_NETWORK" \
                "ParameterKey=VPC,ParameterValue=$VPCID" \
                "ParameterKey=PublicSubnet,ParameterValue=$SUBNETID" \
                --capabilities CAPABILITY_IAM --tags Key=Name,Value=$CLUSTER --region $AWS_REGION)

                #--------------------------------------------------------------------------
                # Wait until stack completes
                #--------------------------------------------------------------------------

                echo "Launching CloudFormation Stack..."
                AWS_PROFILE=$PROFILE aws cloudformation wait stack-create-complete \
                --stack-name $CLUSTER --region $AWS_REGION

                #--------------------------------------------------------------------------
                # return public DNS
                #--------------------------------------------------------------------------
                echo
                echo "Fetching Cluster Information..."


                #return ASG Name from CloudFormation Stack Output

                ASG=$(AWS_PROFILE=$PROFILE aws cloudformation describe-stacks \
                --stack-name $CLUSTER --region $AWS_REGION --query Stacks[].Outputs[].OutputValue --output text)

                #return instance-id and fetch the Public DNS name
                for ID in $(AWS_PROFILE=$PROFILE aws autoscaling describe-auto-scaling-groups \
                --auto-scaling-group-name $ASG --region $AWS_REGION \
                --query AutoScalingGroups[].Instances[].InstanceId --output text)
                do
                INSTANCE=$(AWS_PROFILE=$PROFILE aws ec2 describe-instances --instance-ids $ID --region $AWS_REGION \
                --query Reservations[].Instances[].PublicDnsName --output text)
                done
                HTTP='http://'
                PORT=':54321'
                echo
                echo "Cluster $CLUSTER :"
                echo "################################################################"
                echo "### Link: $HTTP$INSTANCE$PORT"
                echo "################################################################"
                echo
                echo "Done"

                ;;

        [nN] | [nN][Oo] )
                echo "Not agreed, you can't proceed the installation";
                exit 1
                ;;

        *) echo "Invalid input"
            ;;
esac
