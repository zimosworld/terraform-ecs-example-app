#--------------------------------------------------------------
# General
#--------------------------------------------------------------

aws_region = "ap-southeast-2"

tag_application_name        = "ecs-app"
tag_application_environment = "purple"

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

aws_vpc_identifier = "b45dyA4"

#--------------------------------------------------------------
# Application Load Balancer
#--------------------------------------------------------------

alb = {
  security_groups_rules = [
    {
      from_port: 80,
      to_port: 80,
      cidr_block: "0.0.0.0/0"
    },
    {
      from_port: 8080,
      to_port: 8080,
      cidr_block: "0.0.0.0/0"
    },    {
      from_port: 443,
      to_port: 443,
      cidr_block: "0.0.0.0/0"
    },
    {
      from_port: 8443,
      to_port: 8443,
      cidr_block: "0.0.0.0/0"
    },
  ]
  https_listeners  = [
    {
      port: 443,
      target_group_no: 0
    },
    {
      port: 8443,
      target_group_no: 1
    }
  ]
  http_listeners  = [
    {
      port: 80,
      protocol: "HTTP",
      target_group_no: 0
    },
    {
      port: 8080,
      protocol: "HTTP",
      target_group_no: 1
    }
  ]
  target_groups   = [
    {
      name: "purple-tg-blue",
      backend_protocol: "HTTP",
      backend_port: 80
    },
    {
      name: "purple-tg-green",
      backend_protocol: "HTTP",
      backend_port: 80
    }
  ]
  tags = {}
}

#--------------------------------------------------------------
# AutoScaling Group
#--------------------------------------------------------------

autoscaling_group = {
  launch_config = {
    image_search_name = "amzn-ami-*-amazon-ecs-optimized"
    instance_type     = "t2.micro"
    key_name          = "my-key"
  },
  autoscaling_group = {
    max_size          = 1
    min_size          = 1
    health_check_type = "EC2"
    desired_capacity  = 1
  }
}

#--------------------------------------------------------------
# Certifcates
#--------------------------------------------------------------

certificate_domain = "purple-ecs-app.zimosworld.com"

#--------------------------------------------------------------
# CodeDeploy
#--------------------------------------------------------------

codedeploy = {
  deployment_config     = "CodeDeployDefault.ECSAllAtOnce"
  deployment_type       = "BLUE_GREEN"
  rollback_events       = ["DEPLOYMENT_FAILURE"]
  timeout_action        = "STOP_DEPLOYMENT"
  timeout_wait_time     = 1440
  deploy_success_action = "TERMINATE"
  deploy_success_wait   = 1440
  ecs_service_no        = 0
}

#--------------------------------------------------------------
# Database
#--------------------------------------------------------------

aws_rds = [
  {
    storage_type              = "gp2"
    allocated_storage         = "20"
    engine                    = "mariadb"
    engine_version            = "10.3"
    instance                  = "db.t3.micro"
    identifier                = "ecs-app-purple"
    db_name                   = "security"
    username                  = "master"
    parameter_group_name      = "default.mariadb10.3"
    tags                      = {}
  }
]

#--------------------------------------------------------------
# ECS Services
#--------------------------------------------------------------

ecs_service = [
  {
    task_name                   = "ecs-app-purple"
    deployment_controller_type  = "CODE_DEPLOY"
    container_name              = "ecs-app-purple"
    container_port              = 80
    desired_count               = 2
    target_group_no             = 0
    container_definitions       = <<DEFINITION
[
  {
    "name": "ecs-app-purple-web",
    "image": "tutum/hello-world",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 0
      }
    ],
    "memory": 50,
    "cpu": 10
  }
]
DEFINITION
  }
]