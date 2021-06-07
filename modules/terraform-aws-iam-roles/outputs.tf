output "role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.role.arn
}

output "role_name" {
  description = "The name of the role."
  value       = aws_iam_role.role.name
}

output "roles_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.role.*.arn
}

output "role_names" {
  description = "List with the role names."
  value       = aws_iam_role.role.*.name
}

output "instance_profile_name" {
  description = "Instance profile"
  value       = aws_iam_instance_profile.instance_profile.*.name
}

