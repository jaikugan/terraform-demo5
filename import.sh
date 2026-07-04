#!/bin/bash

REGION="us-east-1"
VPC_NAME="Demo-VPC"

echo "========================================="
echo "Terraform Infrastructure Resource IDs"
echo "========================================="

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
  --region $REGION \
  --filters "Name=tag:Name,Values=$VPC_NAME" \
  --query "Vpcs[0].VpcId" \
  --output text)

if [ "$VPC_ID" == "None" ] || [ -z "$VPC_ID" ]; then
    echo "ERROR: VPC with Name tag '$VPC_NAME' not found."
    exit 1
fi

echo "VPC ID                 : $VPC_ID"

# Get Subnet ID
SUBNET_ID=$(aws ec2 describe-subnets \
  --region $REGION \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[0].SubnetId" \
  --output text)

echo "Subnet ID              : $SUBNET_ID"

# Get Internet Gateway ID
IGW_ID=$(aws ec2 describe-internet-gateways \
  --region $REGION \
  --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
  --query "InternetGateways[0].InternetGatewayId" \
  --output text)

echo "Internet Gateway ID    : $IGW_ID"

# Get Route Table ID
ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
  --region $REGION \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "RouteTables[?Associations[?Main==\`false\`]].RouteTableId | [0]" \
  --output text)

echo "Route Table ID         : $ROUTE_TABLE_ID"

# Get Route Table Association ID
RT_ASSOC_ID=$(aws ec2 describe-route-tables \
  --region $REGION \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "RouteTables[?Associations[?Main==\`false\`]].Associations[0].RouteTableAssociationId | [0]" \
  --output text)

echo "Route Table Assoc ID   : $RT_ASSOC_ID"

# Get Security Group ID
SG_ID=$(aws ec2 describe-security-groups \
  --region $REGION \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=terraform-sg" \
  --query "SecurityGroups[0].GroupId" \
  --output text)

echo "Security Group ID      : $SG_ID"

# Get EC2 Instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --region $REGION \
  --filters "Name=tag:Name,Values=Terraform-Server" \
  --query "Reservations[].Instances[].InstanceId | [0]" \
  --output text)

echo "EC2 Instance ID        : $INSTANCE_ID"

echo "========================================="
echo "Terraform Import Commands"
echo "========================================="

echo "terraform import module.vpc.aws_vpc.main $VPC_ID"
echo "terraform import module.vpc.aws_subnet.public $SUBNET_ID"
echo "terraform import module.vpc.aws_internet_gateway.igw $IGW_ID"
echo "terraform import module.vpc.aws_route_table.public $ROUTE_TABLE_ID"
echo "terraform import module.vpc.aws_route_table_association.public $RT_ASSOC_ID"
echo "terraform import module.security_group.aws_security_group.main $SG_ID"
echo "terraform import module.ec2.aws_instance.main $INSTANCE_ID"