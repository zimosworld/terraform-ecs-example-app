#--------------------------------------------------------------
#
# Autoscaling Module for ECS
#
#--------------------------------------------------------------

#--------------------------------------------------------------
# IAM Instance Role
#--------------------------------------------------------------
data "aws_iam_policy_document" "ec2" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name}-ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}

#--------------------------------------------------------------
# IAM Instance Profile
#--------------------------------------------------------------
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-ec2"
  role = aws_iam_role.ec2.name

  depends_on = ["aws_iam_role.ec2"]
}

#--------------------------------------------------------------
# IAM Instance Profile Roles
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ec2" {
  count = length(var.iam_instance_role_policy_arns)

  role       = aws_iam_role.ec2.name
  policy_arn = var.iam_instance_role_policy_arns[count.index]

  depends_on = ["aws_iam_role.ec2"]
}

#--------------------------------------------------------------
# Launch configuration
#--------------------------------------------------------------
data "null_data_source" "ecs_cluster" {

  inputs = {
    default = <<EOF
  #!/bin/bash
  echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
  yum install -y ruby wget
  cd /home/ec2-user
  wget https://aws-codedeploy-ap-southeast-2.s3.ap-southeast-2.amazonaws.com/latest/install
  chmod +x ./install
  ./install auto
  EOF
  }

}

resource "aws_launch_configuration" "default" {
  name                        = "${var.name}-launch-config"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  key_name                    = var.key_name
  security_groups             = var.instance_security_groups
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data == " " && var.ecs_cluster != "" ? data.null_data_source.ecs_cluster.outputs["default"] : var.user_data 
  enable_monitoring           = var.enable_monitoring
  spot_price                  = var.spot_price
  placement_tenancy           = var.spot_price == "" ? var.placement_tenancy : ""
  ebs_optimized               = var.ebs_optimized

  depends_on = ["aws_iam_role.ec2"]

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Autoscaling group
#--------------------------------------------------------------
resource "aws_autoscaling_group" "default" {
  name                 = "${var.name}-autoscaling-group"
  launch_configuration = aws_launch_configuration.default.name

  max_size                  = var.max_size
  min_size                  = var.min_size
  default_cooldown          = var.default_cooldown
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  desired_capacity          = var.desired_capacity
  force_delete              = var.force_delete
  load_balancers            = var.load_balancers
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = var.target_group_arns
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group           = var.placement_group
  metrics_granularity       = var.metrics_granularity
  enabled_metrics           = var.enabled_metrics
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in

  tags = concat(
      list(
        map( "key", "terraform", "value", "true", "propagate_at_launch", true ),
        map( "key", "Name", "value", "${var.name}-asg", "propagate_at_launch", true )
      ),
      var.tags
    )

  lifecycle {
    create_before_destroy = true
  }
}
