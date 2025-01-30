#!/bin/bash

# Simple cleanup script for ECS Fargate stack
set -e

STACK_NAME="ecs-fargate-demo"
REGION="us-east-1"

echo "Starting cleanup..."

# Delete CloudFormation stack
echo "Deleting CloudFormation stack..."
aws cloudformation delete-stack \
    --stack-name ${STACK_NAME} \
    --region ${REGION}

echo "Waiting for stack deletion to complete..."
aws cloudformation wait stack-delete-complete \
    --stack-name ${STACK_NAME} \
    --region ${REGION}

# Delete ECR repository
echo "Cleaning up ECR repository..."
aws ecr delete-repository \
    --repository-name ${STACK_NAME} \
    --force \
    --region ${REGION} || true

echo "Cleanup completed!"