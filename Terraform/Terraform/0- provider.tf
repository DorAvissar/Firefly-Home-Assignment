terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Ensures you get the latest 5.x releases
    }
  }

  required_version = ">= 1.5.0"  # Make sure you're using the latest Terraform CLI version
}


provider "aws" {
  region = "us-east-1" # Specifies the AWS region where the resources will be created
}
