#!/bin/bash
# Simple deployment script for ECS Fargate stack
set -e
STACK_NAME="ecs-fargate-demo"
REGION="us-east-1"
echo "Starting deployment..."
# Build and push Docker image
echo "Building and pushing Docker image..."
cd app
docker build -t ${STACK_NAME} .
# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${STACK_NAME}"
# Create ECR repository if it doesn't exist
aws ecr describe-repositories --repository-names ${STACK_NAME} || \
    aws ecr create-repository --repository-name ${STACK_NAME}
# Login to ECR
aws ecr get-login-password --region ${REGION} | \
    docker login --username AWS --password-stdin ${ECR_REPO}
# Tag and push image
docker tag ${STACK_NAME}:latest ${ECR_REPO}:latest
docker push ${ECR_REPO}:latest
cd ..
# Deploy CloudFormation stack
echo "Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file infrastructure/ecs-fargate-stack.yaml \
    --stack-name ${STACK_NAME} \
    --capabilities CAPABILITY_IAM \
    --region ${REGION} \
    --parameter-overrides \
        ContainerImage=${ECR_REPO}:latest \
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
