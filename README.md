# SvelteKit Serverless AWS Template

A configurable template for deploying serverless SvelteKit applications to AWS using Terraform. Includes a complete developer toolkit with Docker containerization, local development scripts, and pre-configured linting/formatting.

This project comes with TypeScript, Vitest for unit testing, Playwright for browser testing, and uses [adapter-node](https://www.npmjs.com/package/@sveltejs/adapter-node). It's essentially a skeleton SvelteKit application with all the bells and whistles, ready for AWS deployment.

Inspired by [Sean W. Lawrence's post](https://www.sean-lawrence.com/deploying-sveltekit-to-aws-lambda/), [sveltekit-adapter-aws](https://github.com/MikeBild/sveltekit-adapter-aws), and some personal tinkering.

Use this template as-is for quick deployment, or customize it to fit your needs - that's what it's designed for.

# Setup/Usage

## Initial Setup

- Run `git init` if you cloned this template (make sure to remove any existing `.git` folder first)
- **Git Hooks**: Run `npm run prepare` to set up [husky](https://www.npmjs.com/package/husky) pre-commit hooks with [lint-staged](https://www.npmjs.com/package/lint-staged) for automatic linting/formatting
    - Configure hook actions in `.husky/pre-commit`
    - Configure per-file actions in `.lintstagedrc.js` ([docs](https://github.com/okonet/lint-staged#configuration))
- Copy `.env.dev.example` to `.env.dev` and configure your environment variables
- If not using Docker: run `npm install`

## Development with Docker (Recommended)

- Install Docker and the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) + [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) VSCode extensions
- Run `./run-local.sh` to build and start the development container
- Attach VSCode to the running container and navigate to `/home/{SVELTEKIT_PROJECT}` (defaults to `/home/development`)
- Customize the `Dockerfile` and `docker-compose.yml` as needed

## Deployment

Run `./deploy.sh` to build and deploy your application. This will:

- Build the SvelteKit app using adapter-node
- Copy the Lambda template (Express proxy server) to the build folder
- Deploy to AWS Lambda with API Gateway, CloudFront distribution, and S3 for static assets
- Create `deploy.auto.tfvars` for direct Terraform CLI usage
- Optionally invalidate CloudFront cache (set `SVELTEKIT_AUTO_INVALIDATE_CACHE=true` in `.env.dev`)

### Deploy Script Options

- `--auto-approve`: Skip manual approval (mirrors Terraform's flag)
- `--no-build`: Use existing build (requires prior build)

## Cache Management

The template includes automatic CloudFront cache invalidation on deployment. Enable it by setting `SVELTEKIT_AUTO_INVALIDATE_CACHE=true` in your `.env.dev` file. This ensures your latest changes are immediately visible after deployment.

Remember to update the README, LICENSE, and CODE_OF_CONDUCT for your project.

## Custom Domain Setup

You can configure a custom domain using AWS Route 53, though this requires additional setup:

### Prerequisites

- Domain registered in AWS Route 53 with a hosted zone
- Set `SVELTEKIT_DOMAIN_NAME` and `SVELTEKIT_ROUTE53_HOSTED_ZONE_ID` in `.env.dev`
- Optionally set `SVELTEKIT_SUBDOMAIN` (a "www" subdomain is automatically added)

### Cross-Account DNS Management

For DNS managed in a different AWS account, provide `SVELTEKIT_ROUTE53_CROSS_ACCOUNT_ROLE_ARN`. The cross-account role needs these permissions:

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "route53:GetHostedZone",
                    "route53:ListResourceRecordSets",
                    "route53:ChangeResourceRecordSets",
                    "route53:DeleteHostedZone"
                ],
                "Resource": "arn:aws:route53:::hostedzone/*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "route53:GetChange"
                ],
                "Resource": "arn:aws:route53:::change/*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "route53:ChangeTagsForResource"
                ],
                "Resource": [
                    "arn:aws:route53:::hostedzone/*",
                    "arn:aws:route53:::healthcheck/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "route53:CreateHostedZone",
                    "ec2:DescribeVpcs",
                    "route53:ListHostedZones",
                    "route53:GetHostedZoneCount"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "acm:RequestCertificate",
                    "acm:GetCertificate",
                    "acm:AddTagsToCertificate",
                    "acm:DescribeCertificate",
                    "acm:ListTagsForCertificate",
                    "acm:ListCertificates",
                    "acm:DeleteCertificate",
                    "acm:UpdateCertificateOptions",
                    "acm:RemoveTagsFromCertificate"
                ],
                "Resource": "*"
            }
        ]
    }

**Trust Policy:**

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::{ACCOUNT_ID_OF_WHERE_YOU'RE_APPLYING_YOUR_INFRASTRUCTURE}:root"
                },
                "Action": "sts:AssumeRole",
                "Condition": {}
            }
        ]
    }

Optionally provide an external ID via `SVELTEKIT_ROUTE53_CROSS_ACCOUNT_ROLE_EXTERNAL_ID`.

### SSL Certificate

CloudFront requires an ACM certificate for custom domains. You can either:

- Provide an existing certificate ARN via `SVELTEKIT_ACM_CERTIFICATE_ARN` (you handle DNS validation)
- Leave it blank to auto-create one (certificate expires after 1 year, not automatically renewed)

## Additional Notes

- **CI/CD**: Local deployment captures environment variables from `.env`, but you'll need external sources for automated pipelines
- **Line Endings**: Configured for LF line endings via `.gitattributes` and `.prettierrc` - adjust as needed
- **Terraform**: The infrastructure is intentionally minimal - customize the `infra/terraform` modules for your specific needs
- **Caching**: Note that CDN caching hasn't been configured - deliberately so. A caching strategy is for you to decide based upon the needs of your specific application.
- **API Key**: The API Gateway API key added as a header from CloudFront is generated by Terraform. It is treated as sensitive, but it is ultimately stored in state.
