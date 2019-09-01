#--------------------------------------------------------------
#
# Application Load Balancer Module for ECS
#
#--------------------------------------------------------------

resource "aws_lb" "default" {
  load_balancer_type               = "application"
  name                             = "${var.name}-load-balancer"
  internal                         = var.internal
  security_groups                  = var.security_groups
  subnets                          = var.subnets
  idle_timeout                     = var.idle_timeout
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  ip_address_type                  = var.ip_address_type

  tags = merge(
  {
    terraform   = true
    Name        = "${var.name}-load-balancer"
    application = var.application_name
    environment = var.application_environment
  },
  var.tags
  )

  access_logs {
    enabled = true
    bucket  = var.log_bucket_name
    prefix  = var.log_location_prefix
  }

}

resource "aws_lb_target_group" "default" {
  count      = length(var.target_groups)

  name     = var.target_groups[count.index]["name"]
  vpc_id   = var.vpc_id
  port     = var.target_groups[count.index]["backend_port"]
  protocol = upper(var.target_groups[count.index]["backend_protocol"])

  deregistration_delay  = lookup(var.target_groups[count.index], "deregistration_delay", var.target_groups_defaults["deregistration_delay"])
  target_type           = lookup(var.target_groups[count.index], "target_type", var.target_groups_defaults["target_type"])
  slow_start            = lookup(var.target_groups[count.index], "slow_start", var.target_groups_defaults["slow_start"])

  health_check {
    enabled           = lookup(var.target_groups[count.index], "health_check_enabled", var.target_groups_defaults["health_check_enabled"])
    interval          = lookup(var.target_groups[count.index], "health_check_interval", var.target_groups_defaults["health_check_interval"])
    path              = lookup(var.target_groups[count.index], "health_check_path", var.target_groups_defaults["health_check_path"])
    port              = lookup(var.target_groups[count.index], "health_check_port", var.target_groups_defaults["health_check_port"])
    healthy_threshold = lookup(var.target_groups[count.index], "health_check_healthy_threshold", var.target_groups_defaults["health_check_healthy_threshold"])
    unhealthy_threshold = lookup(var.target_groups[count.index], "health_check_unhealthy_threshold", var.target_groups_defaults["health_check_unhealthy_threshold"])
    protocol          = upper(lookup(var.target_groups[count.index], "healthcheck_protocol", var.target_groups[count.index]["backend_protocol"]))
    matcher           = lookup(var.target_groups[count.index], "health_check_matcher", var.target_groups_defaults["health_check_matcher"])
  }

  stickiness {
    type = "lb_cookie"
    cookie_duration = lookup(var.target_groups[count.index], "cookie_duration", var.target_groups_defaults["cookie_duration"])
    enabled         = lookup(var.target_groups[count.index], "stickiness_enabled", var.target_groups_defaults["stickiness_enabled"])
  }

  tags = merge(
  {
    terraform   = true
    Name        = var.target_groups[count.index]["name"]
    application = var.application_name
    environment = var.application_environment
  },
  var.tags
  )

  depends_on = [aws_lb.default]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  count = length(var.http_tcp_listeners)

  load_balancer_arn = aws_lb.default.arn
  port              = var.http_tcp_listeners[count.index]["port"]
  protocol          = var.http_tcp_listeners[count.index]["protocol"]

  default_action {
    target_group_arn = aws_lb_target_group.default[var.http_tcp_listeners[count.index]["target_group_no"]].id
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  count = length(var.https_listeners)

  load_balancer_arn = aws_lb.default.arn
  port            = var.https_listeners[count.index]["port"]
  protocol        = "HTTPS"
  certificate_arn = var.https_certificate_arn
  ssl_policy      = lookup(var.https_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)

  default_action {
    target_group_arn = aws_lb_target_group.default[var.https_listeners[count.index]["target_group_no"]].id
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "https_certs" {
  count = length(var.extra_ssl_certs)

  listener_arn    = aws_lb_target_group.default[var.extra_ssl_certs[count.index]["https_listener_no"]].id
  certificate_arn = var.extra_ssl_certs[count.index]["certificate_arn"]
}
