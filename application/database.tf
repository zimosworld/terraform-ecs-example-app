#--------------------------------------------------------------
#
# Database
#
#--------------------------------------------------------------

#--------------------------------------------------------------
# RDS Security Groups
#--------------------------------------------------------------
resource "aws_security_group" "database" {
  name        = "${var.tag_application_environment}-rds-security-group"
  description = "RDS Security Group"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    security_groups = [aws_security_group.autoscaling_group.id]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    security_groups = [aws_security_group.autoscaling_group.id]
  }

  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "${var.tag_application_environment}-rds-security-group"
    terraform   = "true"
    application = var.tag_application_name
    environment = var.tag_application_environment
    service     = "rds"
  }
}

#--------------------------------------------------------------
# RDS Generate Temp Password
#--------------------------------------------------------------
resource "random_string" "database_password" {
  length  = 21
  special = false
}

#--------------------------------------------------------------
# RDS Instance
#--------------------------------------------------------------
resource "aws_db_instance" "default" {
  count = length(var.aws_rds)

  allocated_storage       = var.aws_rds[count.index]["allocated_storage"]
  storage_type            = var.aws_rds[count.index]["storage_type"]
  engine                  = var.aws_rds[count.index]["engine"]
  engine_version          = var.aws_rds[count.index]["engine_version"]
  instance_class          = var.aws_rds[count.index]["instance"]
  identifier              = var.aws_rds[count.index]["identifier"]
  name                    = var.aws_rds[count.index]["db_name"]
  username                = var.aws_rds[count.index]["username"]
  password                = random_string.database_password.result
  parameter_group_name    = var.aws_rds[count.index]["parameter_group_name"]
  vpc_security_group_ids  = [aws_security_group.database.id]

  tags = merge({
    terraform   = "true"
    application = var.tag_application_name
    environment = var.tag_application_environment
  }, var.aws_rds[count.index]["tags"])

  # Ignore changes to db so we can change in web interface and not have terraform try and overwrite it
  lifecycle {
    ignore_changes = [
      password]
  }
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------

variable "aws_rds" {
  description = "List of RDS configs"
  type        = list(object({
    storage_type         = string
    allocated_storage    = string
    engine               = string
    engine_version       = string
    instance             = string
    identifier           = string
    db_name              = string
    username             = string
    parameter_group_name = string
    tags                 = map(string)
  }))
}
