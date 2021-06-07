resource "aws_iam_role" "role" {
  name        = var.role
  path        = var.role_path
  description = var.role_desc

  # This policy defines who/what is allowed to use the current role
  assume_role_policy = var.policy_file

  # Allow session for X seconds
  max_session_duration  = var.max_session_duration
  force_detach_policies = var.force_detach_policies
}

resource "aws_iam_instance_profile" "instance_profile" {
  count = var.create_instance_profile ? 1 : 0
  name  = var.role
  role  = aws_iam_role.role.name
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = var.role
  count      = length(var.policy_arn)
  policy_arn = element(var.policy_arn, count.index)
  depends_on = [aws_iam_role.role]
}

# attach an extra policy to the role
resource "aws_iam_policy" "extra_policy_declared" {
  count      = var.create_extra_policy ? 1 : 0
  name       = "${var.role}-extra-policy"
  policy     = var.policy
  depends_on = [aws_iam_role.role]
}

resource "aws_iam_role_policy_attachment" "extra_policy_attachment" {
  count = var.create_extra_policy ? 1 : 0

  role       = var.role
  policy_arn = aws_iam_policy.extra_policy_declared[0].arn
  depends_on = [aws_iam_policy.extra_policy_declared]
}

