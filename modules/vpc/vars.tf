variable "vpc_name" {
  default = "vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "region" {
  default = ""
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24,10.0.2.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.3.0/24,10.0.4.0/24"
}
