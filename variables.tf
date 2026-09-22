variable "admin_username" {
  description = "Linux VM administrator username"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Linux VM administrator password"
  type        = string
  sensitive   = true
}