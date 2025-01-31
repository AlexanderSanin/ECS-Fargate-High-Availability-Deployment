#!/bin/bash
set -e

STACK_NAME="ecs-fargate-demo"
REGION="us-east-1"

echo "Starting deployment..."

# Deploy CloudFormation stack using public image
aws cloudformation deploy \
    --template-file infrastructure/ecs-fargate-stack.yaml \
    --stack-name ${STACK_NAME} \
    --capabilities CAPABILITY_IAM \
    --region ${REGION} \
    --parameter-overrides \
        ContainerImage=public.ecr.aws/docker/library/python:3.9-slim \
        ContainerPort=80

# Get the ALB DNS name
echo "Getting ALB DNS name..."
ALB_DNS=$(aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} \
    --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
    --output text)

echo "Deployment completed!"
echo "Application is available at: http://${ALB_DNS}"
echo "Health check endpoint: http://${ALB_DNS}/health"
