provider "aws" {
  region = "${var.region}"
}


module "vpc-us-east-1" {
  source              = "../../modules/vpc"
  vpc_name            = "${var.vpc_name}"
  vpc_cidr            = "${var.vpc_cidr}"
  region              = "${var.region}"
  public_subnet_cidr  = "${var.public_subnet_cidr}"
  private_subnet_cidr = "${var.private_subnet_cidr}"
}

module "segurity-us-east-1" {
  source    = "../../modules/security-group-all"
  vpc_id    = "${module.vpc-us-east-1.vpc_id}"
  protocol  = "${var.protocol}"
  from_port = "${var.from_port}"
  to_port   = "${var.to_port}"
  range     = "${var.range}"
  region    = "${var.region}"
}



 module "key-aws" {
   source                = "../../modules/key-pair"
   region                = "${var.region}"
   ssh_public_key_path   = "${var.ssh_public_key_path}"
   generate_ssh_key      = "${var.generate_ssh_key}"
   ssh_key_algorithm     = "${var.ssh_key_algorithm}"
   private_key_extension = "${var.private_key_extension}"
   public_key_extension  = "${var.public_key_extension}"
}

