locals {
  name = "softuni-db-workshop"

  linux_ami = "ami-0cfda02b23b35e070"

  vpc_cidr_block              = "10.0.0.0/16"
  public_subnet_cidr_block    = "10.0.1.0/24"
  private_subnet_1_cidr_block = "10.0.2.0/24"
  private_subnet_2_cidr_block = "10.0.3.0/24"
}

variable "public_key" {
  description = "Your public SSH key here"
}
