output "autoscaling_group_name" {
  value = aws_autoscaling_group.wordpress.name
}

output "autoscaling_group_id" {
  value = aws_autoscaling_group.wordpress.id
}

output "launch_configuration_id" {
  value = aws_launch_template.wordpress.id
}

output "desired_capacity" {
  value = aws_autoscaling_group.wordpress.desired_capacity
}