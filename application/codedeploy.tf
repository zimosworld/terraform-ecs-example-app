#--------------------------------------------------------------
#
# CodeDeploy
#
#--------------------------------------------------------------

#--------------------------------------------------------------
# IAM Instance Role
#--------------------------------------------------------------
resource "aws_iam_role" "default" {
  name = "${var.tag_application_name}-${var.tag_application_environment}-codedploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#--------------------------------------------------------------
# IAM Instance Role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  count = length(var.iam_codedeploy_role_policy_arns)

  policy_arn = var.iam_codedeploy_role_policy_arns[count.index]
  role       = aws_iam_role.default.name
}

#--------------------------------------------------------------
# Codedeploy Application
#--------------------------------------------------------------
resource "aws_codedeploy_app" "default" {
  compute_platform = "ECS"
  name             = "${var.tag_application_name}-${var.tag_application_environment}-ecs-cluster"
}

#--------------------------------------------------------------
# Codedeploy Deployment Group
#--------------------------------------------------------------
resource "aws_codedeploy_deployment_group" "default" {
  app_name               = aws_codedeploy_app.default.name
  deployment_config_name = var.codedeploy["deployment_config"]
  deployment_group_name  = "${var.tag_application_name}-${var.tag_application_environment}-deployment-group"
  service_role_arn       = aws_iam_role.default.arn

  auto_rollback_configuration {
    enabled = true
    events  = var.codedeploy["rollback_events"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout     = var.codedeploy["timeout_action"]
      wait_time_in_minutes  = var.codedeploy["timeout_wait_time"]
    }

    terminate_blue_instances_on_deployment_success {
      action                           = var.codedeploy["deploy_success_action"]
      termination_wait_time_in_minutes = var.codedeploy["deploy_success_wait"]
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = var.codedeploy["deployment_type"]
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.default.name
    service_name = aws_ecs_service.default[var.codedeploy["ecs_service_no"]].name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [module.alb.http_listener_arns[0]]
      }

      test_traffic_route {
        listener_arns = [module.alb.http_listener_arns[1]]
      }

      target_group {
        name = module.alb.target_group_names[0]
      }

      target_group {
        name = module.alb.target_group_names[1]
      }
    }
  }
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "iam_codedeploy_role_policy_arns" {
  description = "Policys to attach to the code deploy role"
  type        = "list"
  default     = [
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
    "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  ]
}

variable "codedeploy" {
  description = "Map of codedeploy configs"
  type        = object({
    deployment_config     = string
    deployment_type       = string
    rollback_events       = list(string)
    timeout_action        = string
    timeout_wait_time     = number
    deploy_success_action = string
    deploy_success_wait   = number
    ecs_service_no        = number
  })
}
