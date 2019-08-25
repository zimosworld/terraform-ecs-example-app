#--------------------------------------------------------------
# Backend
#--------------------------------------------------------------

terraform {
  backend "remote" {
    organization = "container-testing"

    workspaces {
      prefix = "ecs-container-env-"
    }
  }
}

