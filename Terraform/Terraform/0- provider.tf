terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Specifies the AWS provider source from HashiCorp's registry
      version = "~> 5.0"        # Specifies the AWS provider version (any 5.x version)
    }
  }
}

provider "aws" {
  region = "us-east-1" # Specifies the AWS region where the resources will be created
}
