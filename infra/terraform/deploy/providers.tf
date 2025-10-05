terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
  default_tags {
    tags = {
      Terraform = true
    }
  }
}

# If no route53_domain_cross_account_assume_role_configuration variable was 
# provided, then we won't need this.
provider "aws" {
  alias = "route53"

  profile = var.aws_profile
  region  = var.aws_region
  default_tags {
    tags = {
      Terraform = true
    }
  }

  dynamic "assume_role" {
    for_each = var.route53_domain_cross_account_assume_role_configuration != null ? [1] : []

    content {
      role_arn     = var.route53_domain_cross_account_assume_role_configuration.role_arn
      session_name = "route53-${var.route53_domain_cross_account_assume_role_configuration.session_name}"
      external_id  = var.route53_domain_cross_account_assume_role_configuration.external_id != "" ? var.route53_domain_cross_account_assume_role_configuration.external_id : null
    }
  }
}

provider "aws" {
  alias = "acm"

  profile = var.aws_profile
  region  = "us-east-1" # Certificate must be in us-east-1
  default_tags {
    tags = {
      Terraform = true
    }
  }
}
