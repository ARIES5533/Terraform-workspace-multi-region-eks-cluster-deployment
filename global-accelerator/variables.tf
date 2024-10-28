variable "region" {
  description = "AWS region"
  type        = string
}

variable "access_key" {
    type = string
    sensitive = true
    default = "" 
}

variable "secret_key" {
    type = string
    sensitive = true
    default = ""
}