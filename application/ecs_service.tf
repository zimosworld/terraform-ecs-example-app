#--------------------------------------------------------------
#
# ECS Service
#
#--------------------------------------------------------------

#--------------------------------------------------------------
# IAM Instance Role
#--------------------------------------------------------------
data "aws_iam_policy_document" "ecs-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-service-role" {
  name                = "${var.tag_application_name}-${var.tag_application_environment}-ecs-service"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.ecs-service-policy.json
}

#--------------------------------------------------------------
# IAM Instance Profile Roles
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
  role       = aws_iam_role.ecs-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

#--------------------------------------------------------------
# ECS Task Definition
#--------------------------------------------------------------
resource "aws_ecs_task_definition" "default" {
  family                = "hello_world"
  container_definitions = <<DEFINITION
[
  {
    "name": "hello-world",
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

#--------------------------------------------------------------
# ECS Service
#--------------------------------------------------------------
resource "aws_ecs_service" "default" {
  name            = "${var.tag_application_name}-${var.tag_application_environment}-ecs-service"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn

  desired_count   = 1

  deployment_controller {
    type = var.ecs_service["deployment_controller_type"]
  }

  load_balancer {
    target_group_arn  = module.alb.target_group_arns[0]
    container_name    = var.ecs_service["container_name"]
    container_port    = var.ecs_service["container_port"]
  }
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "ecs_service" {
  description = "Map of ECS Service configs."
  type        = object({
    deployment_controller_type  = string
    container_name              = string
    container_port              = number
  })
}
