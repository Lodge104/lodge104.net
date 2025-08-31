output "autoscaling_group_name" {
  value = aws_autoscaling_group.wordpress_asg.name
}

output "autoscaling_group_id" {
  value = aws_autoscaling_group.wordpress_asg.id
}

output "launch_configuration_id" {
  value = aws_launch_configuration.wordpress_lc.id
}

output "desired_capacity" {
  value = aws_autoscaling_group.wordpress_asg.desired_capacity
}