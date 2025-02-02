![IMG_2633](https://github.com/user-attachments/assets/459cdbb9-a5eb-45de-a10f-6f050ca4b670)# ECS Fargate High-Availability Deployment

This project demonstrates a production-ready deployment of a containerized application on AWS ECS Fargate with high availability and security features.


Screenshot of deployed application:
Endpoint: http://ecs-fa-appli-fybrc3spv2va-293964297.us-east-1.elb.amazonaws.com/
![IMG_2633](https://github.com/user-attachments/assets/86725f0d-4cbd-444f-b3ae-159cef799fe0)


## Project Structure

```
.
├── README.md
├── buildspec.yml    
├── app/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
├── infrastructure/
│   └── ecs-fargate-stack.yaml
└── scripts/
    ├── deploy.sh
    ├── setup.sh
    └── cleanup.sh
```

## Prerequisites

1. AWS Account and CLI configured
2. Docker installed
3. Basic understanding of AWS services (ECS, CloudFormation)

## Quick Start

1. **Clone the repository**
```bash
git clone <repository-url>
cd ecs-fargate-deployment
```

2. **Setup Git credentials, Build and deploy the application**
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Configure git credentials helper for AWS CodeCommit
./scripts/setup.sh

# Deploy the stack
./scripts/deploy.sh
```

3. **Verify the deployment**
```bash
# Get the ALB DNS name
export ALB_DNS=$(aws cloudformation describe-stacks \
    --stack-name ecs-fargate-demo \
    --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
    --output text)

# Test the endpoint
curl http://$ALB_DNS/health
```

4. **Clean up resources**
```bash
./scripts/cleanup.sh
```

## Infrastructure Features

- Multi-AZ deployment
- Auto-scaling based on CPU utilization
- Application Load Balancer with health checks
- Private subnets for containers
- CloudWatch logging and monitoring
- Rolling deployments

## Security Features

- Containers run in private subnets
- Security groups restrict access
- IAM roles follow least privilege principle
- No hardcoded credentials

## Deployment Verification

Check these points to verify successful deployment:

1. CloudFormation stack is complete
2. ECS tasks are running
3. ALB health checks are passing
4. Application is accessible via ALB
5. CloudWatch logs show container output

## Troubleshooting

Common issues and solutions:

1. Stack Creation Fails
   - Check CloudFormation events
   - Verify IAM permissions
   - Check VPC limits

2. Container Health Checks Failing
   - Check security group rules
   - Verify container logs
   - Check task definition

## Cleanup

Run the cleanup script to remove all resources:
```bash
./scripts/cleanup.sh
```

## Cost Considerations

- NAT Gateway: ~$32/month
- ALB: ~$16/month
- Fargate: Based on usage
- CloudWatch: Based on log volume


