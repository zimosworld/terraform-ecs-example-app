variable "name" {
  description = "Unique name prefix for resources created in this module."
}

variable "ecs_cluster" {
  description = ""
  default     = ""
}

#--------------------------------------------------------------
# IAM Instance Profile Roles
#--------------------------------------------------------------
variable "iam_instance_role_policy_arns" {
  description = "List of policy ARNs to attach to role. Only applies if iam_instance_profile is empty."
  type        = "list"
  default     = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}

#--------------------------------------------------------------
# Launch configuration
#--------------------------------------------------------------
variable "image_id" {
  description = "The EC2 image ID to launch."
}

variable "instance_type" {
  description = "The size of instance to launch."
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to associate with launched instances. Will auto create one if empty."
  default     = ""
}

variable "key_name" {
  description = "The key name that should be used for the instance."
}

variable "instance_security_groups" {
  description = "A list of security group IDs to assign to EC2 instances."
  type        = "list"
  default     = []
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC."
  default     = false
}

variable "user_data" {
  description = "The user data to provide when launching the instance."
  default     = " "
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring."
  default     = true
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  default     = false
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance."
  type        = "list"
  default     = []
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance."
  type        = "list"
  default     = []
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as 'Instance Store') volumes on the instance."
  type        = "list"
  default     = []
}

variable "spot_price" {
  description = "The maximum price to use for reserving spot instances. [On-demand price]"
  default     = ""
}

variable "placement_tenancy" {
  description = "The tenancy of the instance. [default, dedicated]"
  default     = "default"
}

#--------------------------------------------------------------
# Autoscaling group
#--------------------------------------------------------------
variable "max_size" {
  description = "The maximum size of the auto scale group."
}

variable "min_size" {
  description = "The minimum size of the auto scale group."
}

variable "default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
  default     = 300
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health."
  default     = 300
}

variable "health_check_type" {
  description = "Controls how health checking is done. [EC2, ELB]"
  default     = "EC2"
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group."
}

variable "force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate."
  default     = false
}

variable "load_balancers" {
  description = "A list of classic load balancer names to add to the autoscaling group names."
  type        = "list"
  default     = []
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in."
  type        = "list"
  default     = []
}

variable "target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  type        = "list"
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. [OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default]"
  type        = "list"
  default     = ["OldestInstance"]
}

variable "suspended_processes" {
  description = "A list of processes to suspend for the AutoScaling Group. [Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZRebalance, AlarmNotification, ScheduledActions, AddToLoadBalancer]"
  type        = "list"
  default     = []
}

variable "tags" {
  description = "A list of tag blocks."
  type        = "list"
  default     = []
}

variable "placement_group" {
  description = "The name of the placement group into which you'll launch your instances."
  default     = ""
}

variable "metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute"
  default     = "1Minute"
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. [GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances]"
  type        = "list"
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  default     = "10m"
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events."
  default     = false
}