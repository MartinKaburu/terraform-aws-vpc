variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default = "10.0.2.0/24"
}

variable "ami" {
  description = "AMI for EC2"
  default = "ami-0f65671a86f061fcd"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/Users/martinmuguna/.ssh/id_rsa.pub"
}
