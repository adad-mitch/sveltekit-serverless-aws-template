# SvelteKit Serverless AWS Template

This is a moderately configurable template for getting a serverless SvelteKit application quickly deployed to AWS, using Terraform. It's also a bit of a developer toolkit, containing a Dockerfile & docker-compose.yml; local development utility scripts; linting and formatting configurations that may be of convenience. This particular project is configured to use TypeScript, Vitest for unit testing, Playwright for browser testing, uses [adapter-node](https://www.npmjs.com/package/@sveltejs/adapter-node) and has a simple "Welcome to SvelteKit" page at the root (i.e., a skeleton SvelteKit application with all the additional options selected when creating a new project from the CLI).

This was inspired by a mix of [this post by Sean W. Lawrence](https://www.sean-lawrence.com/deploying-sveltekit-to-aws-lambda/), [sveltekit-adapter-aws](https://github.com/MikeBild/sveltekit-adapter-aws), and my own strange musings.

Feel free to use this however suits; this is deliberately a template so that you can get started with minimal configuration, but equally lets you add/modify/remove components however you fancy (as is how I've been using it for kickstarting my own things).

# Setup/Usage

-   Do a `git init`; make sure you don't have the `.git` folder carried over from this template if you cloned it.
    -   **Git Hooks**: You can do `npm run prepare` to set up the [husky](https://www.npmjs.com/package/husky) pre-commit hook, which uses [lint-staged](https://www.npmjs.com/package/lint-staged) to run appropriate linters/formatters etc. on staged files, and does an `npm run check` ([svelte-check](https://www.npmjs.com/package/svelte-check)) on everything Svelte.
        -   You can configure the actions taken by the pre-commit hook in the `.husky/pre-commit` script.
        -   You can configure the actions to take on each staged file with lint-staged in the `.lintstagedrc.js` file. [See more here](https://github.com/okonet/lint-staged#configuration).
-   Take a look at the `.env.dev.example` file. Environment variables pertaining to the containerised development and deployment processes are documented here. If you want to configure any of them, create a copy called `.env.dev` and configure as you like.
-   If you're not planning to use the container (though I would suggest you do), do an `npm install` here. If you are using the container, that'll be done for you when it starts up.
-   **If you are planning to develop inside the container**:
    -   First, make sure you have Docker installed and running on your host machine, as well as the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) and [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) extensions for VSCode.
    -   Run the `run-local.sh` script with Bash. This will build the `Dockerfile`, then cleans up any containers running the old image and does a `docker compose up` using the `docker-compose.yml`. The container does a `sleep infinity`, so this will continue running for as long as the terminal is held open (allowing you to develop in there).
    -   Attach VSCode to the container from the Docker extension tab, by right-clicking the running container and choosing "Attach Visual Studio Code". More on this [here](https://code.visualstudio.com/docs/devcontainers/attach-container). Once in there, `cd` into the `/home/{SVELTEKIT_PROJECT}` directory (defaults to `/home/development`).
        -   You can of course configure the `Dockerfile` directly - for instance, if you want to install additional packages out of the box, etc. The same goes for the `docker-compose.yml`.
-   **When you want to deploy your application**:
    -   Run the `deploy.sh` script. Make sure you've configured any environment variables you want to use - for example the AWS profile or region, etc.
        -   By default, this will build the application using the Node adapter, copy the contents of the `infra/lambda-template` (a tiny package that uses an Express server to proxy requests through to a handler - in our case, the built SvelteKit `handler.js` file) into the configured build folder, and deploy that to Lambda, fronted by an API Gateway Lambda Proxy, a CloudFront distribution, and an S3 bucket for any static assets.
            -   It also creates a `deploy.auto.tfvars` file in the `infra/terraform/deploy` folder, so you can destroy infrastructure, run plans etc. directly from the Terraform CLI as usual with the same variables.
            -   You can change the Terraform to suit your needs directly in the `infra/terraform` folder - it is fairly minimalist as it stands - see [here](#other-things-to-consider).
        -   `--auto-approve` flag: This mirrors Terraform's flag of the same name, which skips the manual approval step when running `terraform apply`.
        -   `--no-build` flag: Skips the build step and uses whatever is currently in the specified build folder (default `build`). Requires that a build has been done before.
-   Remember to change the README, LICENSE, CODE_OF_CONDUCT etc. to fit your project.

## Using a custom domain name

There is the option of setting up a custom domain with AWS Route 53 pointing to the generated CloudFront distribution, but it's a little more invested than the rest of the configurations...

-   You will need to have the desired domain registered beforehand in AWS Route 53, and this should have its own hosted zone that you can provide the ID for.
    - As usual, see the `.env.dev.example` file for the environment variables, but pertinent to this bit of the configuration are the `SVELTEKIT_DOMAIN_NAME` and `SVELTEKIT_ROUTE53_HOSTED_ZONE_ID` variables.
-   You can just use the domain apex, in which case, you can leave the `SVELTEKIT_SUBDOMAIN` environment variable blank, but you can provide a subdomain (or a chain of them) if you like (a "www" subdomain will be added to whatever concatenation of subdomain + domain name you have provided, and the site will be accessible with or without it).

If the infrastructure you're provisioning sits in the same AWS account as the AWS Route 53 hosted zone that you want to use, then you can skip this step. However, it's a pretty common use case for people to have their DNS stuff centrally-managed in one account and other bits of infrastructure elsewhere. Therefore, the template allows you to provide the ARN of a role that can be assumed in another account, to manage the hosted zone and AWS Certificate Manager (ACM) certificates. The environment variable to pass this into is `SVELTEKIT_ROUTE53_CROSS_ACCOUNT_ROLE_ARN`, and the role in the account with the hosted zone should look something like the following:

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

(Yeah, this isn't the world's most tightly locked-down IAM role - you could probably restrict it down to particular ARNs and such when you drop it into your own account.)

The trust policy should look something like this:

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

You can also provide an external ID for assuming the role if you like via the `SVELTEKIT_ROUTE53_CROSS_ACCOUNT_ROLE_EXTERNAL_ID` environment variable.

Lastly, your CloudFront distribution will need an ACM certificate to prove you control the domain you want to use. This will need to be provisioned in the account you want your infrastructure in (afaik you can't use a certificate between accounts). You can create one yourself and provide the ARN for it with the `SVELTEKIT_ACM_CERTIFICATE_ARN` environment variable, but you will need to do all of the DNS validation and management of the certificate yourself. Alternatively, if you leave that environment variable blank, the Terraform will create one for you - though note that it doesn't keep track of expiry of that certificate (will be after 1 year).

## Other things to consider...

-   As of writing, ^4.4.0 versions of Vite seem to cause a problem when changing environment variables or Svelte/Vite config files, where the dev server crashes, rather than simply restarting. That's why this is using v4.3.9.
-   Everything here should work well locally, but things obviously change when using an automated environment. For example, the build will capture application environment variables in a `.env` if you deploy from your machine, but you will need an external source for these in a pipeline.
-   The repository is configured to force use of LF rather than CRLF wherever possible. This is enforced by the `.gitattributes` file, as well as the `.prettierrc` file - feel free to change formatting etc. to whatever suits you.
