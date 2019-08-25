#--------------------------------------------------------------
#
# Backend
#
#--------------------------------------------------------------

terraform {
  backend "remote" {
    organization = "container-testing"

    workspaces {
      name = "ecs-container-global"
    }
  }
}