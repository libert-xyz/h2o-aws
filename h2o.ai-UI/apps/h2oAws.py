import boto3
import os
from botocore.exceptions import ClientError


AWS_REGION = 'us-east-1'
AZ = 'us-east-1a'
KEY = 'myAws'
#NUMBER_INSTANCES = '1'
ALLOWED_NETWORK = '0.0.0.0/0'

###
#stack = 'boto3-stack'
INSTANCE_TYPE = 't2.micro'


DIR = os.path.dirname(os.path.abspath(os.path.join(os.pardir,'h2o.ai','aws','h2o_cluster.yml')))

def get_default_vpc():

    client = boto3.client('ec2')
    try:
        response = client.describe_vpcs(
            Filters=[
                {
                    'Name':'isDefault',
                    'Values': [
                        'true'
                              ]
                }])

        r = response['Vpcs'][0]['VpcId']
        #return vpc-id String
        return r

    except ClientError as e:
        return e


def get_subnet_id(vpcId):

    client = boto3.client('ec2')
    try:
        response = client.describe_subnets(
            Filters=[
                {
                    'Name': 'vpc-id',
                    'Values' : [
                            vpcId
                                ]
                },
                {
                'Name' : 'availabilityZone',
                'Values' : [
                        AZ
                            ]
                }])

        return response['Subnets'][0]['SubnetId']

    except ClientError as e:
        return e


def create_stack(name,number):

    vpcid = get_default_vpc()
    subnetid = get_subnet_id(vpcid)

    templateObject = open(DIR+'/h2o_cluster.yml')
    client = boto3.client('cloudformation')

    try:
        response = client.create_stack(
            StackName=name,
            TemplateBody= templateObject.read(),
            Parameters=[
                {
                    'ParameterKey' : "KeyName",
                    'ParameterValue' : KEY,
                    'UsePreviousValue': True
                },
                {
                    'ParameterKey' : "InstanceType",
                    'ParameterValue' : INSTANCE_TYPE
                },
                {
                    'ParameterKey' : "vmCount",
                    'ParameterValue' : number
                },
                {
                    'ParameterKey' : "SSHLocation",
                    'ParameterValue' : ALLOWED_NETWORK
                },
                {
                    'ParameterKey' : "VPC",
                    'ParameterValue' : vpcid
                },
                {
                    'ParameterKey' : "PublicSubnet",
                    'ParameterValue' : subnetid
                }],

            Capabilities=['CAPABILITY_IAM'],
            Tags=[
                {
                    'Key': 'Name',
                    'Value': name
                }]
        )

        templateObject.close()
        return response

    except ClientError as e:
        return e
