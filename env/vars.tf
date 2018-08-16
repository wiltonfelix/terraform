##### VPC VARS #####
variable "vpc_name" {
  default = "vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "region" {
  default = "us-east-1"
}

##### SECURITY GROUP VARS #####
variable "protocol" {
  default = "tcp"
}

variable "from_port" {
  default = "0"
}

variable "to_port" {
  default = "65535"
}

variable "range" {
  default = "0.0.0.0/0"
}

##### KEY SSH VARS ####

variable "ssh_public_key_path" {
  description = "Path to Read/Write SSH Public Key File (directory)"
  default     = "../aws-regions/us-east-1/keys"
}

variable "generate_ssh_key" {
  default = "true"
}

variable "ssh_key_algorithm" {
  default = "RSA"
}

variable "private_key_extension" {
  type    = "string"
  default = ".pem"
}

variable "public_key_extension" {
  type    = "string"
  default = ".pub"
}
