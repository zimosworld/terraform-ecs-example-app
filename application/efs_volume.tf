#--------------------------------------------------------------
#
# EFS Volume
#
#--------------------------------------------------------------

#--------------------------------------------------------------
# EFS File System
#--------------------------------------------------------------
resource "aws_efs_file_system" "default" {
  encrypted   = true
  kms_key_id  = aws_kms_key.efs.arn

  tags = {
    Name        = "${var.tag_application_environment}-${var.tag_application_environment}-volume"
    terraform   = "true"
    application = var.tag_application_name
    environment = var.tag_application_environment
  }

  depends_on = [aws_kms_key.efs]
}

#--------------------------------------------------------------
# EFS Security Groups
#--------------------------------------------------------------
resource "aws_security_group" "efs" {
  name        = "${var.tag_application_environment}-efs-security-group"
  description = "EFS Security Group"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    security_groups = [aws_security_group.autoscaling_group.id]
  }

  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    security_groups = [aws_security_group.autoscaling_group.id]
  }

  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "${var.tag_application_environment}-efs-security-group"
    terraform   = "true"
    application = var.tag_application_name
    environment = var.tag_application_environment
    service     = "asg"
  }
}

#--------------------------------------------------------------
# EFS Mount Target
#--------------------------------------------------------------
resource "aws_efs_mount_target" "default" {
  count = length(local.efs_subnet_ids_list)

  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = local.efs_subnet_ids_list[count.index]
  security_groups = [aws_security_group.efs.id]

  depends_on = [aws_efs_file_system.default]
}

## Workaround bug with using index from subnet list throwing "This value does not have any indices."
locals {
  efs_subnet_ids = join(",", data.aws_subnet_ids.private_subnets.ids)
  efs_subnet_ids_list = split(",", local.efs_subnet_ids)
}

#--------------------------------------------------------------
# EFS KMS Key
#--------------------------------------------------------------
resource "aws_kms_key" "efs" {
  description             = "${var.tag_application_environment}-${var.tag_application_environment}-efs-key"
  deletion_window_in_days = 10
}
