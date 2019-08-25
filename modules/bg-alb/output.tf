output "alb_arn" {
  value = aws_lb.default.arn
}

output "alb_dns" {
  value = aws_lb.default.dns_name
}

output "http_listener_arns" {
  value = aws_lb_listener.http.*.arn
}

output "http_listener_ids" {
  value = aws_lb_listener.http.*.arn
}

output "target_group_arns" {
  value = aws_lb_target_group.default.*.arn
}

output "target_group_names" {
  value = aws_lb_target_group.default.*.name
}