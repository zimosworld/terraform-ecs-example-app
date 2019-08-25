#--------------------------------------------------------------
#
# Provider
#
#--------------------------------------------------------------

provider "aws" {
  region = var.aws_region
  version = "~> 2.7"
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "aws_region" {
  description = "Region for the VPC"
}

variable "tag_application_name" {
  description = "Application name tag"
}

variable "tag_application_environment" {
  description = "Application environment tag"
}

