terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or specify the version you need
    }
  }
}


provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}