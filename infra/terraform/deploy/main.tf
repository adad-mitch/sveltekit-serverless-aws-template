module "lambda_proxy" {
  source                    = "../modules/api-gw-lambda"
  aws_profile               = var.aws_profile
  resource_prefix           = local.aws_resource_prefix
  lambda_name               = local.default_service_name
  lambda_handler_name       = var.deployment_lambda_handler_name
  lambda_handler_runtime    = var.deployment_lambda_handler_runtime
  lambda_source_path        = local.build_artefact_path
  api_gateway_name          = "${local.default_service_name}-proxy"
  api_gateway_description   = "A simple API Gateway that proxies requests through to a single Lambda function."
  api_deployment_stage_name = local.default_deployment_stage_name
}

module "static_bucket" {
  source                    = "../modules/static-asset-s3"
  resource_prefix           = local.aws_resource_prefix
  bucket_name               = "${local.default_service_name}-static"
  static_assets_source_path = "${local.build_artefact_path}client/"
  cf_dist_arns              = [module.cdn.arn]
}

module "cdn" {
  source                         = "../modules/ssr-cf-dist"
  aws_profile                    = var.aws_profile
  resource_prefix                = local.aws_resource_prefix
  s3_bucket_id                   = module.static_bucket.id
  s3_bucket_regional_domain_name = module.static_bucket.bucket_regional_domain_name

  # Stripping HTTPS and the stage name away to produce the raw domain name
  api_gw_domain_name           = replace(module.lambda_proxy.api_invoke_url, "/^https?://([^/]*).*/", "$1")
  api_gw_deployment_stage_name = "/${local.default_deployment_stage_name}"
  api_gw_api_key               = module.lambda_proxy.api_key
  acm_certificate_arn          = var.domain_name != "" ? var.acm_certificate_arn != "" ? var.acm_certificate_arn : module.certificate[0].arn : ""

  alternate_cnames = var.domain_name != "" && var.route53_hosted_zone_id != "" ? [
    "${local.subdomain}${var.domain_name}",
    "www.${local.subdomain}${var.domain_name}"
  ] : []
}

module "routing" {
  count = var.domain_name != "" && var.route53_hosted_zone_id != "" ? 1 : 0
  providers = {
    aws = aws.route53
  }
  source          = "../modules/alias-route53"
  resource_prefix = local.aws_resource_prefix
  hosted_zone_id  = var.route53_hosted_zone_id
  domain_name     = var.domain_name
  subdomain       = local.subdomain
  alias_configuration = {
    name                   = module.cdn.domain_name
    zone_id                = module.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

module "certificate" {
  count = var.domain_name != "" && var.route53_hosted_zone_id != "" && var.acm_certificate_arn == "" ? 1 : 0
  providers = {
    aws.acm     = aws.acm
    aws.route53 = aws.route53
  }
  source          = "../modules/acm-dns-cert"
  resource_prefix = local.aws_resource_prefix
  domain_name     = var.domain_name
  subdomain       = local.subdomain
  hosted_zone_id  = var.route53_hosted_zone_id
}
