#!/bin/bash
set -e

STACK_NAME="ecs-fargate-demo"
REGION="us-east-1"

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/ecs-fargate-demo:latest"

# Ensure the ECR repository exists
aws ecr describe-repositories --repository-names ecs-fargate-demo || \
    aws ecr create-repository --repository-name ecs-fargate-demo

# Start CodeBuild project and wait for completion
echo "Starting CodeBuild project..."
BUILD_ID=$(aws codebuild start-build --project-name ecs-fargate-demo --query 'build.id' --output text)
echo "Build ID: $BUILD_ID"

echo "Waiting for build to complete..."
while true; do
    BUILD_STATUS=$(aws codebuild batch-get-builds --ids $BUILD_ID --query 'builds[0].buildStatus' --output text)
    echo "Build status: $BUILD_STATUS"
    if [ "$BUILD_STATUS" = "SUCCEEDED" ]; then
        break
    elif [ "$BUILD_STATUS" = "FAILED" ] || [ "$BUILD_STATUS" = "FAULT" ] || [ "$BUILD_STATUS" = "STOPPED" ]; then
        echo "Build failed with status: $BUILD_STATUS"
        exit 1
    fi
    sleep 10
done

# Deploy CloudFormation stack
echo "Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file infrastructure/ecs-fargate-stack.yaml \
    --stack-name ${STACK_NAME} \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
        ContainerImage=${ECR_REPO} \
        ContainerPort=80

# Get the ALB DNS name
echo "Getting ALB DNS name..."
ALB_DNS=$(aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} \
    --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
    --output text)

echo "Deployment completed!"
echo "Application is available at: http://${ALB_DNS}"
