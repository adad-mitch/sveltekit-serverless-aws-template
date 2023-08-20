#!/usr/bin/env bash

# Second counter to log script runtime
SECONDS=0

# The directory of the script; serves as a "root" of execution
SCRIPT_DIR=$(pwd)

# Convenient colour vars
red=$(tput setaf 1)
readonly red
green=$(tput setaf 2)
readonly green
yellow=$(tput setaf 3)
readonly yellow
blue=$(tput setaf 4)
readonly blue
normal=$(tput sgr0)
readonly normal

# Arg parsing vars
readonly arg_options=("auto_approve" "no_build")

# Error logging and exit utility function
function error_and_exit() {
    printf "%sERROR: $1; exiting...%s\n" "${red}" "${normal}"
    exit 1
}

# Standardised informative success log utility function
function log_success() {
    printf "%sSUCCESS: $1\n%s" "${green}" "${normal}"
}

# Standardised informative warning log utility function
function log_warning() {
    printf "%sWARNING: $1\n%s" "${yellow}" "${normal}"
}

# Standardised informative logging utility function
function log_info() {
    printf "%sINFO: $1\n%s" "${blue}" "${normal}"
}

# Utility function to retrieve environment variables from a .env file
# in the same directory, for use in the script.
function source_env() {
    local env_file=".env.dev"
    log_info "Configuring environment variables from $env_file file"
    local restore_shell
    
    # Disable alias expansion only in this scope
    case $- in
    (*a*) restore_shell=;;
(*)   restore_shell='set +a';;
esac
    
    if [ -f "$env_file" ]; then
        while IFS= read -r line; do
            # Remove comments and any leading/trailing whitespace
            local line
            line="$(echo "$line" | sed 's/#.*//;s/[[:space:]]*$//')"
            if [[ "$line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*= ]]; then
                export "${line?}"
            fi
        done < "$env_file"
    else
        log_info "No env file '$env_file' found; skipping..."
    fi
    
    eval "$restore_shell"
}

# Arg parser; allowed format is --{ARG_NAME} {VALUE (if applicable)}.
while [ $# -gt 0 ]; do
    valid_arg=false
    if [[ $1 == "--"* ]]; then
        passed_arg="${1/--/}" # The arg as it was passed in by the user, without "--"
        arg="${passed_arg//-/_}"
        for opt in "${arg_options[@]}"; do
            if [[ "${arg,,}" == "${opt,,}" ]]; then
                valid_arg=true
                if [[ -z "$2" || "$2" == --* ]]; then
                    declare "$arg"=true
                else
                    declare "$arg"="$2"
                fi
                break
            fi
        done
        if [[ $valid_arg == false ]]; then
            error_and_exit "unknown argument '$passed_arg'"
        fi
    fi
    shift
done


# Build the SvelteKit application.
function build() {
    log_info "Building SvelteKit application in '$SVELTEKIT_BUILD_PATH'..."
    log_info "Using Lambda template from '$SVELTEKIT_LAMBDA_TEMPLATE_PATH'..."
    npm run build || error_and_exit "npm build failed"
    
    # This is just to ensure package.json and package-lock.json are in sync
    log_info "Running preliminary install on Lambda template files..."
    cd "$SVELTEKIT_LAMBDA_TEMPLATE_PATH" || error_and_exit "failed to change to lambda template directory"
    npm install || error_and_exit "preliminary npm install failed"
    cd "$SVELTEKIT_SCRIPT_DIR" || error_and_exit "failed to change to script root directory"
    
    # Copy everything except node_modules and the handler, since this is a
    # placeholder file
    log_info "Copying Lambda template files into build directory..."
    find "$SVELTEKIT_LAMBDA_TEMPLATE_PATH" -type f -name 'handler.js' \
    -prune -o -name 'node_modules' -prune -o -type f -exec cp {} "$SVELTEKIT_BUILD_PATH" \; || \
    error_and_exit "failed to copy lambda template into build directory"
    
    log_info "Installing build dependencies..."
    cd "$SVELTEKIT_BUILD_PATH" || error_and_exit "failed to change to build directory"
    npm ci --omit dev || error_and_exit "npm ci failed"
    cd "$SCRIPT_DIR" || error_and_exit "failed to change to script root directory"
}

# Deploy the application with Terraform.
function deploy() {
    log_info "Checking out Terraform, in '$SVELTEKIT_TERRAFORM_PATH'..."
    cd "$SVELTEKIT_TERRAFORM_PATH/deploy" || \
    error_and_exit "failed to change to deployment directory"
    
    log_info "Initialising Terraform..."
    sudo terraform init || error_and_exit "terraform init failed"
    
    log_info "Creating .tfvars file..."
    local tf_vars_string="build_artefact_path = \"$SVELTEKIT_BUILD_PATH\""$'\n'
    if [ -n "$SVELTEKIT_AWS_PROFILE" ]; then
        tf_vars_string+="aws_profile = \"$SVELTEKIT_AWS_PROFILE\""$'\n'
        log_info "Using custom AWS profile: '$SVELTEKIT_AWS_PROFILE'..."
    fi
    if [ -n "$SVELTEKIT_AWS_REGION" ]; then
        tf_vars_string+="aws_region = \"$SVELTEKIT_AWS_REGION\""$'\n'
        log_info "Using custom AWS region: '$SVELTEKIT_AWS_REGION'..."
    fi
    if [ -n "$SVELTEKIT_AWS_RESOURCE_PREFIX" ]; then
        tf_vars_string+="aws_resource_prefix = \"$SVELTEKIT_AWS_RESOURCE_PREFIX\""$'\n'
        log_info "Using custom AWS resource prefix: '$SVELTEKIT_AWS_RESOURCE_PREFIX'..."
    fi
    if [ -n "$SVELTEKIT_LAMBDA_HANDLER_NAME" ]; then
        tf_vars_string+="deployment_lambda_handler_name = \"$SVELTEKIT_LAMBDA_HANDLER_NAME\""$'\n'
        log_info "Using custom AWS Lambda handler: '$SVELTEKIT_LAMBDA_HANDLER_NAME'..."
    fi
    if [ -n "$SVELTEKIT_NODE_RUNTIME" ]; then
        # AWS requires the full runtime string, i.e., "nodejsXX.x" as opposed to just "XX".
        tf_vars_string+="deployment_lambda_handler_runtime = \"nodejs$SVELTEKIT_NODE_RUNTIME.x\""$'\n'
        log_info "Using custom Node runtime: '$SVELTEKIT_NODE_RUNTIME'..."
    fi
    
    echo -n "$tf_vars_string" > deploy.auto.tfvars
    terraform fmt ./deploy.auto.tfvars
    
    # Technically the SECONDS variable accounts for the time spent at the
    # approval stage, but in automation environments, you would probably
    # want to auto approve - and this is where knowing the time taken
    # would be more important (i.e., performance monitoring, etc.).
    log_info "Running Terraform apply..."
    if [ "$1" == true ]; then
        terraform apply --auto-approve || error_and_exit "terraform apply failed or was cancelled"
    else
        terraform apply || error_and_exit "terraform apply failed or was cancelled"
    fi
    
    local cf_domain
    cf_domain=$(terraform output -raw cloudfront_domain)
    
    log_info "Verifying successful deployment..."
    expected_status_code=200
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "https://$cf_domain")
    
    if [ "$status_code" -eq $expected_status_code ]; then
        log_success "Your SvelteKit application is live at https://$cf_domain 🎉"
    else
        log_warning "Your SvelteKit application has been deployed to https://$cf_domain, but did not get a $expected_status_code status code back (Got $status_code)."
    fi
}

# Build the SvelteKit application and deploy it using Terraform.
function build_and_deploy() {
    build && deploy "$1"
}


source_env

# Default environment variables if not provided.
build_path="build"
terraform_path="infra/terraform"
lambda_template_path="infra/lambda-template"
SVELTEKIT_BUILD_PATH="$(pwd)/${SVELTEKIT_BUILD_PATH:-$build_path}"
SVELTEKIT_TERRAFORM_PATH="$(pwd)/${SVELTEKIT_TERRAFORM_PATH:-$terraform_path}"
SVELTEKIT_LAMBDA_TEMPLATE_PATH="$(pwd)/${SVELTEKIT_LAMBDA_TEMPLATE_PATH:-$lambda_template_path}"

# Validates that the provided directories actually exist.
if [[ -n "$SVELTEKIT_TERRAFORM_PATH" && ! -d "$SVELTEKIT_TERRAFORM_PATH" ]]; then
    error_and_exit "'$SVELTEKIT_TERRAFORM_PATH' is not a valid path"
fi
if [[ -n "$SVELTEKIT_LAMBDA_TEMPLATE_PATH" && ! -d "$SVELTEKIT_LAMBDA_TEMPLATE_PATH" ]]; then
    error_and_exit "'$SVELTEKIT_LAMBDA_TEMPLATE_PATH' is not a valid path"
fi

export SVELTEKIT_BUILD_PATH
export SVELTEKIT_TERRAFORM_PATH
export SVELTEKIT_LAMBDA_TEMPLATE_PATH

# shellcheck disable=SC2154  # Dynamically created vars
if [ "$no_build" == true ]; then
    log_info "--no-build specified; attempting to use an existing build..."
    if [[ ! -d "$SVELTEKIT_BUILD_PATH" ]]; then
        error_and_exit "if --no-build is specified, a build must already be present"
    else
        deploy "$auto_approve"
    fi
else
    build_and_deploy "$auto_approve"
fi

log_info "Script took $SECONDS seconds."
