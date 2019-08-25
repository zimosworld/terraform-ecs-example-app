#--------------------------------------------------------------
#
# ECS Cluster
#
#--------------------------------------------------------------
resource "aws_ecs_cluster" "default" {
  name = "${var.tag_application_name}-${var.tag_application_environment}-ecs-cluster"

  tags = {
    terraform: true,
    application: var.tag_application_name,
    environment: var.tag_application_environment
  }
}