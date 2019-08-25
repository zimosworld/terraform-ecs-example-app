#--------------------------------------------------------------
#
# SSH Key
#
#--------------------------------------------------------------

resource "aws_key_pair" "ssh-key" {
  key_name   = var.aws_ssh_key["name"]
  public_key = var.aws_ssh_key["public_key"]
}

#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "aws_ssh_key" {
  description = "SSH Key"
  type = object({
    name        = string
    public_key  = string
  })
}