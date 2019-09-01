#--------------------------------------------------------------
#
# Certificate
#
#--------------------------------------------------------------

data "aws_acm_certificate" "default" {
  domain    = var.certificate_domain
  statuses  = ["ISSUED"]
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------

variable "certificate_domain" {
  description = "The domain of the certificate to look up."
}
