
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}


variable "vpc_id" {
    default = ""
}


variable "vpc_private_subnets" {
    description = "List of subnet IDs for the EKS cluster"
    type        = list(string)
}


variable "vpc_public_subnets" {
    description = "List of subnet IDs for the EKS cluster"
    type        = list(string)
}