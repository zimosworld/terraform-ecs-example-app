
variable "application_name" {
  description = ""
}

variable "application_environment" {
  description = ""
}

variable "vpc_id" {
  description = "VPC id where the load balancer and other resources will be deployed."
}

#--------------------------------------------------------------
# Application Load Balancer
#--------------------------------------------------------------

variable "name" {
  description = "Name."
}

variable "internal" {
  description = "If true, the LB will be internal."
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the LB."
  type        = list(string)
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the LB."
  type        = list(string)
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60
}

variable "enable_cross_zone_load_balancing" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer."
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in application load balancers."
  type        = bool
  default     = true
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. [ipv4, dualstack]"
  default     = "ipv4"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "log_bucket_name" {
  description = "The S3 bucket name to store the logs in."
}

variable "log_location_prefix" {
  description = "The S3 bucket prefix. Logs are stored in the root if not configured."
  default     = "alb"
}

#--------------------------------------------------------------
# Target Groups
#--------------------------------------------------------------

variable "target_groups" {
  description = ""
  type        = "list"
}

variable "target_groups_defaults" {
  description = "Default values for target groups."
  type = object({
    cookie_duration                  = string,
    deregistration_delay             = string,
    health_check_enabled             = bool,
    health_check_interval            = string,
    health_check_healthy_threshold   = string,
    health_check_path                = string,
    health_check_port                = string,
    health_check_timeout             = string,
    health_check_unhealthy_threshold = string,
    health_check_matcher             = string,
    stickiness_enabled               = string,
    target_type                      = string,
    slow_start                       = string,
  })
  default = {
    cookie_duration                  = 86400
    deregistration_delay             = 300
    health_check_enabled             = true
    health_check_interval            = 10
    health_check_healthy_threshold   = 3
    health_check_path                = "/"
    health_check_port                = "traffic-port"
    health_check_timeout             = 5
    health_check_unhealthy_threshold = 3
    health_check_matcher             = "200-299"
    stickiness_enabled               = true
    target_type                      = "instance"
    slow_start                       = 0
  }
}

#--------------------------------------------------------------
# Listeners
#--------------------------------------------------------------

variable "http_tcp_listeners" {
  description = "List of HTTP/TCP Listeners"
  type        = "list"
  default     = []
}

variable "https_listeners" {
  description = "List of HTTPS Listeners"
  type        = "list"
  default     = []
}

variable "https_certificate_arn" {
  description = "Default Certifcate ARN for HTTPS Listeners"
  default     = ""
}

variable "listener_ssl_policy_default" {
  description = "The security policy for HTTPS Listener. https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies"
  default     = "ELBSecurityPolicy-2016-08"
}

variable "extra_ssl_certs" {
  description = "List of extra certificates to add to the HTTPS Listeners."
  type        = list(object({
    certificate_arn = string,
    https_listener_no = number
  }))
  default     = []
}
