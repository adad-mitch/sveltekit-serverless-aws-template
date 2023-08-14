# SvelteKit Serverless AWS Template

This is a moderately configurable template for getting a serverless SvelteKit application quickly deployed to AWS, using Terraform. It's also a bit of a developer toolkit, containing a Dockerfile & docker-compose.yml; local development utility scripts; linting and formatting configurations that may be of convenience. This particular project is configured to use TypeScript, Vitest for unit testing, uses [adapter-node](https://www.npmjs.com/package/@sveltejs/adapter-node) and has a simple "Welcome to SvelteKit" page at the root (i.e., a Skeleton SvelteKit application).

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

## Other things to consider...

-   As of writing, ^4.4.0 versions of Vite seem to cause a problem when changing environment variables or Svelte/Vite config files, where the dev server crashes, rather than simply restarting. That's why this is using v4.3.9.
-   Everything here should work well locally, but things obviously change when using an automated environment. For example, the build will capture application environment variables in a `.env` if you deploy from your machine, but you will need an external source for these in a pipeline.
-   The repository is configured to force use of LF rather than CRLF wherever possible. This is enforced by the `.gitattributes` file, as well as the `.prettierrc` file - feel free to change formatting etc. to whatever suits you.
-   Admittedly, while the Terraform is highly reusable (you should be able to transplant it elsewhere and use it out of the box for similar workloads), it's fairly inflexible. There are a few things I thought about configuring support for, including multiple environments, setting up a CNAME record in front of CloudFront, log retention configuration, etc. - and I may add these things later on if I can think of an approach that wouldn't sacrifice the speed and simplicity of the template.
