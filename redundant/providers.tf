terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  profile    = var.aws_access_key == null ? var.aws_profile : null
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = merge(var.tags, {
      ManagedBy = "Terraform"
      Stack     = var.name_prefix
    })
  }
}
