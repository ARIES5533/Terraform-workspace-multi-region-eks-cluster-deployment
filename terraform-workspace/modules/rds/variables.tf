variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "db_subnet_group_name" {
    default = ""
}


variable "db_security_group_id" {
  description = "Security group ID for the primary database"
  type        = string
}


variable "db_username" {
  type        = string
  default = "postgres"
}

variable "db_password" {
  type        = string
  sensitive   = true 
  default = "postgres"
}