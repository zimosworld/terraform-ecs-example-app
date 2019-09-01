#--------------------------------------------------------------
#
# Certificate
#
#--------------------------------------------------------------

resource "aws_acm_certificate" "default" {
  count = length(var.certificates)

  domain_name               = var.certificates[count.index]["domain_name"]
  subject_alternative_names = var.certificates[count.index]["subject_alternative_names"]
  validation_method         = var.certificates[count.index]["validation_method"]

  tags = {
    terraform   = true
    application = var.certificates[count.index]["application"]
    environment = var.certificates[count.index]["environment"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------

variable "certificates" {
  type = list(object({
    domain_name               = string
    subject_alternative_names = list(string)
    validation_method         = string
    application               = string
    environment               = string
  }))
}
