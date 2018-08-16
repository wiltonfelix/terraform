variable "vpc_name" {
  default = "vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "region" {
  default = ""
}

variable "subnets" {
  type = "map"

  default = {
    private = 1
    public  = 1
  }
}
