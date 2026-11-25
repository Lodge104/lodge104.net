output "role_arn" {
  description = "ARN of the Amplify service role."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the Amplify service role."
  value       = aws_iam_role.this.name
}
