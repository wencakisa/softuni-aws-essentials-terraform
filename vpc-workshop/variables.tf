variable "profile" {
  description = "AWS profile to use (see ~/.aws/credentials)"
  default     = "default"
}

variable "region" {
  description = "AWS Region to launch resources in"
  default     = "eu-central-1"
}

variable "public_key_path" {
  description = "Path to your public SSH key here"
  default     = "~/.ssh/id_rsa.pub"
}

variable "name" {
  description = "Application name"
  default     = "softuni-workshop"
}

variable "ami" {
  description = "OS AMI"
  default     = "ami-0cfda02b23b35e070" # Linux 64-bit
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "Public subnet CIDR block"
  default     = "10.0.1.0/18"
}
