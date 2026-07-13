module "vpc" {

  source = "./modules/vpc"

  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.public_subnet_cidr
  availability_zone = var.availability_zone

}

module "security_group" {

  source = "./modules/security_group"

  vpc_id = module.vpc.vpc_id

}

module "ec2" {

  source = "./modules/ec2"

  ami           = var.ami
  instance_type = var.instance_type

  subnet_id = module.vpc.subnet_id

  security_group_id = module.security_group.sg_id

}

# new