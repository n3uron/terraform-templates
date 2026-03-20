terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.0"
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

provider "mongodbatlas" {
  client_id     = var.atlas_client_id
  client_secret = var.atlas_client_secret
}
