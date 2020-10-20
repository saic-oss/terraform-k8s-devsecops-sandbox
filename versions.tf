terraform {
  required_version = ">= 0.13.0, < 0.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0, < 3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.0.0, < 2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0.0, < 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0.0, < 3.0.0"
    }
  }
}
