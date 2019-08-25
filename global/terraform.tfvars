
#--------------------------------------------------------------
#
# Global Terraform Varaiables
#
#--------------------------------------------------------------

#--------------------------------------------------------------
# General
#--------------------------------------------------------------

aws_region            = "ap-southeast-2"

#--------------------------------------------------------------
# VPC
#--------------------------------------------------------------

aws_vpc_production = {
  name = "ecs-production"
  cidr = "10.0.16.0/20"
  availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  public_subnets = ["10.0.16.0/24", "10.0.19.0/24", "10.0.22.0/24"]
  private_subnets = ["10.0.17.0/24", "10.0.20.0/24", "10.0.23.0/24"]
  database_subnets = ["10.0.18.0/24", "10.0.21.0/24", "10.0.24.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  public_subnet_tags = { subnet_type = "public" }
  private_subnet_tags = { subnet_type = "private" }
  database_subnet_tags = { subnet_type = "database" }
  tags = {}
  vpc_tags = {
    environment = "production"
    identifier = "2fH8nZ"
  }
}

aws_vpc_purple = {
  name = "ecs-pruple"
  cidr = "10.0.16.0/20"
  availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  public_subnets = ["10.0.16.0/24", "10.0.19.0/24", "10.0.22.0/24"]
  private_subnets = ["10.0.17.0/24", "10.0.20.0/24", "10.0.23.0/24"]
  database_subnets = ["10.0.18.0/24", "10.0.21.0/24", "10.0.24.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  public_subnet_tags = { subnet_type = "public" }
  private_subnet_tags = { subnet_type = "private" }
  database_subnet_tags = { subnet_type = "database" }
  tags = {}
  vpc_tags = {
    environment = "purple"
    identifier = "b45dyA4"
  }
}

#--------------------------------------------------------------
# SSH Key
#--------------------------------------------------------------

aws_ssh_key = {
  name        = "my-key"
  public_key  = "ssh-rsa AAAAB3tJ3gTH0r2miQjqB"
}
