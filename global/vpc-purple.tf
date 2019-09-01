#--------------------------------------------------------------
#
# AWS VPC
#
#--------------------------------------------------------------

module "vpc-purple" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.aws_vpc_purple["name"]
  cidr = var.aws_vpc_purple["cidr"]

  azs              = var.aws_vpc_purple["availability_zones"]
  public_subnets   = var.aws_vpc_purple["public_subnets"]
  private_subnets  = var.aws_vpc_purple["private_subnets"]
  database_subnets = var.aws_vpc_purple["database_subnets"]

  enable_nat_gateway = var.aws_vpc_purple["enable_nat_gateway"]
  single_nat_gateway = var.aws_vpc_purple["single_nat_gateway"]

  public_subnet_tags   = var.aws_vpc_purple["public_subnet_tags"]
  private_subnet_tags  = var.aws_vpc_purple["private_subnet_tags"]
  database_subnet_tags = var.aws_vpc_purple["database_subnet_tags"]

  enable_dns_hostnames = true

  tags = merge({
    terraform   = "true"
  }, var.aws_vpc_purple["tags"])

  vpc_tags = var.aws_vpc_purple["vpc_tags"]
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "aws_vpc_purple" {
  description = "Object with VPC settings"
  type        = object({
    name                 = string
    cidr                 = string
    availability_zones   = list(string)
    public_subnets       = list(string)
    private_subnets      = list(string)
    database_subnets     = list(string)
    enable_nat_gateway   = bool
    single_nat_gateway   = bool
    public_subnet_tags   = map(string)
    private_subnet_tags  = map(string)
    database_subnet_tags = map(string)
    tags                 = map(string)
    vpc_tags             = map(string)
  })
}
