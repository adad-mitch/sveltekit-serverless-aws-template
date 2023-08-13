#!/usr/bin/env bash

# Convenient colour vars
red=$(tput setaf 1)
readonly red
blue=$(tput setaf 4)
readonly blue
normal=$(tput sgr0)
readonly normal

# Standardised informative logging utility function
function log_info() {
    printf "%sINFO: $1\n%s" "${blue}" "${normal}"
}

# Error logging and exit utility function
function error_and_exit() {
    printf "%sERROR: $1; exiting...%s\n" "${red}" "${normal}"
    exit 1
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


# Builds/rebuilds the Docker image, cleaning up any old containers
# and dangling images left as a byproduct of a rebuild.
function build_clean() {
    local existing_containers existing_images current_images dangling_images
    log_info "Removing containers using the existing image..."
    existing_containers=$(docker ps -aq --filter "ancestor=$SVELTEKIT_DEVTOOLS_IMAGE_NAME")
    if [ -n "$existing_containers" ]; then
        docker rm -f "$existing_containers" || error_and_exit "Failed to remove existing container"
    fi
    existing_images=$(docker images -q "$SVELTEKIT_DEVTOOLS_IMAGE_NAME")
    
    log_info "Setting file permissions..."
    chmod +x ./* # The container should keep this permission when built

    log_info "Building the Docker image..."
    docker build -t "$SVELTEKIT_DEVTOOLS_IMAGE_NAME" --build-arg NODE_VERSION="$SVELTEKIT_NODE_VERSION" \
    --build-arg PROJECT="$SVELTEKIT_PROJECT" --build-arg TF_VERSION="$SVELTEKIT_TF_VERSION" . || \
    error_and_exit "Docker build failed"
    
    log_info "Removing dangling images..."
    current_images=$(docker images -q "$SVELTEKIT_DEVTOOLS_IMAGE_NAME")
    dangling_images=$(comm -13 <(echo "$current_images") <(echo "$existing_images"))
    if [ -n "$dangling_images" ]; then
        docker rmi "$dangling_images" || log_info "Failed to remove dangling images; non-fatal."
    fi
}

# Runs the docker services (i.e., the devtools container), using
# `docker compose up`, which holds the process open.
function run_local() {
    docker compose up || error_and_exit "Docker compose failed"
}


source_env

# Validates that the provided directories actually exist.
if [[ -n "$SVELTEKIT_AWS_PATH" && ! -d "$SVELTEKIT_AWS_PATH" ]]; then
    error_and_exit "'$SVELTEKIT_AWS_PATH' is not a valid absolute path"
fi
if [[ -n "$SVELTEKIT_GIT_CONFIG_PATH" && ! -d "$SVELTEKIT_GIT_CONFIG_PATH" ]]; then
    error_and_exit "'$SVELTEKIT_GIT_CONFIG_PATH' is not a valid absolute path"
fi

# (Sort of) Validates that the provided host ports are valid port numbers
num_re='^(?!-)[0-9]+$'
if [[ -n "$SVELTEKIT_BUILD_PORT" && (! ("$SVELTEKIT_BUILD_PORT" =~ $num_re) || $SVELTEKIT_BUILD_PORT -gt 65535) ]]; then
    error_and_exit "'$SVELTEKIT_BUILD_PORT' value for argument 'build_port' must be a valid port number"
fi
if [[ -n "$SVELTEKIT_DEV_PORT" && (! ("$SVELTEKIT_DEV_PORT" =~ $num_re) || $SVELTEKIT_DEV_PORT -gt 65535) ]]; then
    error_and_exit "'$SVELTEKIT_DEV_PORT' value for argument 'dev_port' must be a valid port number"
fi

# Default environment variables if not provided.
export SVELTEKIT_DEVTOOLS_IMAGE_NAME="${SVELTEKIT_DEVTOOLS_IMAGE_NAME:-devtools}"
export SVELTEKIT_DEVTOOLS_CONTAINER_NAME="${SVELTEKIT_DEVTOOLS_CONTAINER_NAME:-devtools}"
export SVELTEKIT_PROJECT="${SVELTEKIT_PROJECT:-development}"
export SVELTEKIT_GIT_CONFIG_PATH="${SVELTEKIT_GIT_CONFIG_PATH:-$HOME/.gitconfig}"
export SVELTEKIT_AWS_PATH="${SVELTEKIT_AWS_PATH:-$HOME/.aws}"
export SVELTEKIT_NODE_VERSION="${SVELTEKIT_NODE_VERSION:-18}"
export SVELTEKIT_TF_VERSION="${SVELTEKIT_TF_VERSION:-1.5.0}"
export SVELTEKIT_DEV_PORT="${SVELTEKIT_DEV_PORT:-5173}"
export SVELTEKIT_BUILD_PORT="${SVELTEKIT_BUILD_PORT:-4173}"

log_info "Exported container configuration environment variables with the following values:"
log_info "SVELTEKIT_PROJECT: $SVELTEKIT_PROJECT"
log_info "SVELTEKIT_DEVTOOLS_IMAGE_NAME: $SVELTEKIT_DEVTOOLS_IMAGE_NAME"
log_info "SVELTEKIT_DEVTOOLS_CONTAINER_NAME: $SVELTEKIT_DEVTOOLS_CONTAINER_NAME"
log_info "SVELTEKIT_GIT_CONFIG_PATH: $SVELTEKIT_GIT_CONFIG_PATH"
log_info "SVELTEKIT_AWS_PATH: $SVELTEKIT_AWS_PATH"
log_info "SVELTEKIT_NODE_VERSION: $SVELTEKIT_NODE_VERSION"
log_info "SVELTEKIT_TF_VERSION: $SVELTEKIT_TF_VERSION"
log_info "SVELTEKIT_DEV_PORT: $SVELTEKIT_DEV_PORT"
log_info "SVELTEKIT_BUILD_PORT: $SVELTEKIT_BUILD_PORT"

build_clean
run_local
