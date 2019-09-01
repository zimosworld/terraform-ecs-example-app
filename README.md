# ECS with Blue Green Deployments

This is an example using Terraform to deploy ECS using EC2 with Blue Green deployments using CodeDeploy. 

## Terraform

In this example Terraform is spill up into global and application.

### Global

Global handles infrastructure that is shared between multiple applications or environments.

Example
- A Production VPC mite hold three different websites that are managed in three separate repos.
- Or ECR which is used for one application but all environments (production and staging)

Global is run once overall and will setup:

- Beanstalk application for "EB Single Container App"
- SSH Key
- VPC for Production environment
- VPC for Purple (Staging) environment

Path: `global`

### Application

Application handles infrastructure related only to that applications environment.

Example
- Each application and environment will have its own database
- Each application and environment will have its own ECS Cluster and EC2 Cluster

Application is run for each environment and will setup for each environment:

- Application Load Balancer
- AutoScaling Group
- ECS Cluster
- ECS Service (Example)
- Code Deploy (For Example ECS Service)
 
Path: `application`

### Setup

- Run terraform commands* for Global.
- Run terraform commands* for each Application environment.

*See readme in global/application folder for commands. 

### To Do

- Add logging and S3 Buckets to store logs
- Add Deployment config for Bitbucket or other 
- Documentation for how to deploy using CodeDeploy
