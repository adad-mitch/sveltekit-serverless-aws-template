resource "null_resource" "wait_for_cert_validation" {
  triggers = {
    certificate_arn = var.acm_certificate_arn
  }

  provisioner "local-exec" {
    # Poll to ensure provided certificate is of "issued" status (in case it was recently provisioned), for up to 15 minutes.
    # It really shouldn't take this long most of the time, but DNS propagation can be unpredictable.
    # If there is no certificate, just exit. Performing this check inside the command, rather than as a "count" at the resource
    # level because it means we can use a depends_on argument inside the CloudFront distribution resource properly.
    command = <<EOT
      if [ -z "${var.acm_certificate_arn}" ]; then
        exit 0
      else
        end_time=$(( $(date +%s) + 900 ))
        until [ "$(date +%s)" -ge "$end_time" ] || \
        aws acm describe-certificate \
        --profile ${var.aws_profile} \
        --region us-east-1 \
        --certificate-arn ${var.acm_certificate_arn} \
        --query 'Certificate.Status' \
        --output text | grep -q 'ISSUED'; do
            sleep 30
        done
      fi
    EOT
  }
}
