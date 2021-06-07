variable "role" {
  description = "Define role"
}

variable "role_path" {
  description = "The path under which to create the role."
  default     = "/"
}

variable "role_desc" {
  description = "The description of the role."
  default     = "Managed by Terraform"
}

variable "policy_file" {
}

variable "max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours."
  default     = "3600"
}

variable "force_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying it."
  default     = true
}

variable "create_instance_profile" {
  default = false
}

# -------------------------------------------------------------------------------------------------
# Default Policy settings
# -------------------------------------------------------------------------------------------------

variable "policy_arn" {
  type = list(string)

  default = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
}

variable "create_extra_policy" {
  description = "Whether to create an extra policy for the role"
  default     = false
}

variable "policy" {
  description = "extra policy"
  default     = ""
}
