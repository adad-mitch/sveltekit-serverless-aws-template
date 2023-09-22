terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.7.0"
      configuration_aliases = [aws.acm, aws.route53]
    }
  }
}
