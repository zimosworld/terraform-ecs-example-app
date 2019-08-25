#--------------------------------------------------------------
#
# ECS Module - Application Load Balancer
#
#--------------------------------------------------------------

#--------------------------------------------------------------
# ALB Security Groups
#--------------------------------------------------------------
resource "aws_security_group" "abl_group" {
  name        = "${var.tag_application_environment}-alb-security-group"
  description = "Application Load Balancer Security Group"

  dynamic "ingress" {
    for_each = var.alb["security_groups_rules"]
    content {
      from_port = ingress.value.from_port
      to_port   = ingress.value.to_port
      protocol  = "tcp"
      cidr_blocks = [ingress.value.cidr_block]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "${var.tag_application_environment}-alb-security-group"
    terraform   = "true"
    application = var.tag_application_name
    environment = var.tag_application_environment
    service     = "alb"
  }
}

#--------------------------------------------------------------
# Application Load Balancer Module
#--------------------------------------------------------------
module "alb" {
  source  = "../modules/bg-alb"

  application_environment = var.tag_application_environment
  application_name        = var.tag_application_name

  name               = "${var.tag_application_name}-${var.tag_application_environment}"
  security_groups    = [aws_security_group.abl_group.id]
  subnets            = data.aws_subnet_ids.public_subnets.ids
  tags               = var.alb["tags"]
  vpc_id             = data.aws_vpc.default.id
  //https_listeners    = var.alb["https_listeners"]
  http_tcp_listeners = var.alb["http_listeners"]
  target_groups      = var.alb["target_groups"]
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "alb" {
  description = "Map of configs for application load balancer."
  type        = object({
    security_groups_rules = list(map(string))
    tags            = map(string)
    https_listeners = list(map(string))
    http_listeners  = list(map(string))
    target_groups   = list(map(string))
  })
}
