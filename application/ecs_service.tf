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
  name                = "${var.tag_application_name}-${var.tag_application_environment}-ecs-web-service"
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
  count = length(var.ecs_service)

  family                = "${var.tag_application_name}-${var.tag_application_environment}-${var.ecs_service[count.index]["task_name"]}"
  container_definitions = var.ecs_service[count.index]["container_definitions"]
}

#--------------------------------------------------------------
# ECS Service
#--------------------------------------------------------------
resource "aws_ecs_service" "default" {
  count = length(var.ecs_service)

  name            = "${var.tag_application_name}-${var.tag_application_environment}-${var.ecs_service[count.index]["task_name"]}"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default[count.index].arn
  desired_count   = var.ecs_service[count.index]["desired_count"]

  deployment_controller {
    type = var.ecs_service[count.index]["deployment_controller_type"]
  }

  load_balancer {
    target_group_arn  = module.alb.target_group_arns[var.ecs_service[count.index]["target_group_no"]]
    container_name    = var.ecs_service[count.index]["container_name"]
    container_port    = var.ecs_service[count.index]["container_port"]
  }
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "ecs_service" {
  description = "Map of ECS Service configs."
  type        = list(object({
    task_name                   = string
    deployment_controller_type  = string
    container_name              = string
    container_port              = number
    container_definitions       = string
    desired_count               = number
    target_group_no             = number
  }))
}
