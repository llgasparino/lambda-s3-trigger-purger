terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.3"
    }
  }

  # Configure seu backend S3 para armazenar o estado
  backend "s3" {
    bucket = "meu-bucket-de-estado-terraform" # <-- Mude para seu bucket
    key    = "lambda-s3-purger/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}