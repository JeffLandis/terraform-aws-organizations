terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source = "opentofu/aws"
      version = ">= 5.65"
    }
  }
}
