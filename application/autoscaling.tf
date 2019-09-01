#--------------------------------------------------------------
#
# ECS Module - Autoscaling Group
#
#--------------------------------------------------------------

data "aws_ami" "app" {
  most_recent = true

  filter {
    name = "name"
    values = [var.autoscaling_group["launch_config"]["image_search_name"]]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

#--------------------------------------------------------------
# EC2 Security Groups
#--------------------------------------------------------------
resource "aws_security_group" "autoscaling_group" {
  name        = "${var.tag_application_environment}-asg-security-group"
  description = "Autoscaling Group Security Group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.alb_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "${var.tag_application_environment}-asg-security-group"
    terraform   = "true"
    application = var.tag_application_name
    environment = var.tag_application_environment
    service     = "asg"
  }
}

#--------------------------------------------------------------
# Autoscaling Group Module
#--------------------------------------------------------------
module "autoscaling_group" {
  source = "../modules/ecs-autoscaling"

  name                        = "${var.tag_application_name}-${var.tag_application_environment}"
  ecs_cluster                 = "${var.tag_application_name}-${var.tag_application_environment}-ecs-cluster"
  image_id                    = data.aws_ami.app.image_id
  instance_type               = var.autoscaling_group["launch_config"]["instance_type"]
  key_name                    = var.autoscaling_group["launch_config"]["key_name"]
  instance_security_groups    = [aws_security_group.autoscaling_group.id]

  max_size                  = var.autoscaling_group["autoscaling_group"]["max_size"]
  min_size                  = var.autoscaling_group["autoscaling_group"]["min_size"]
  health_check_type         = var.autoscaling_group["autoscaling_group"]["health_check_type"]
  desired_capacity          = var.autoscaling_group["autoscaling_group"]["desired_capacity"]
  vpc_zone_identifier       = data.aws_subnet_ids.private_subnets.ids
  target_group_arns         = module.alb.target_group_arns

  efs_system_id = aws_efs_file_system.default.id

  tags = [
    {
      key                 = "application"
      value               = var.tag_application_name
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = var.tag_application_environment
      propagate_at_launch = true
    },
  ]
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "autoscaling_group" {
  description = "Map of autoscaling group configs."
  type        = object({
    launch_config = object({
      image_search_name           = string
      instance_type               = string
      key_name                    = string
    }),
    autoscaling_group = object({
      max_size                  = string
      min_size                  = string
      health_check_type         = string
      desired_capacity          = number
    })
  })
}
