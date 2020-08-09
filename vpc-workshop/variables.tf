variable "profile" {
  type        = string
  description = "AWS profile to use (see ~/.aws/credentials)"
  default     = "default"
}

variable "region" {
  type        = string
  description = "AWS Region to launch resources in"
  default     = "eu-central-1"
}

variable "public_key_path" {
  type        = string
  description = "Path to your public SSH key here"
  default     = "~/.ssh/id_rsa.pub"
}

variable "name" {
  type        = string
  description = "Application name"
  default     = "softuni-workshop"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Count of availability zones to launch instances in"
  default     = 2
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ec2_ami" {
  type        = string
  description = "EC OS AMI"
  default     = "ami-0cfda02b23b35e070" # Linux 64-bit
}
