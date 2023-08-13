locals {
  # VARIABLE OVERRIDES #
  # Where locals exist with the same name as a variable, use the local version instead.

  # Add the hyphen on to the resource prefix if it exists, if it doesn't leave empty
  aws_resource_prefix = var.aws_resource_prefix != "" ? "${var.aws_resource_prefix}-" : ""

  # Ensure a trailing slash, whether one was provided or not
  build_artefact_path = substr(var.build_artefact_path, -1, 1) == "/" ? var.build_artefact_path : "${var.build_artefact_path}/"

  # ------------------ #

  default_service_name          = "sveltekit-service"
  default_deployment_stage_name = "prod"
}
