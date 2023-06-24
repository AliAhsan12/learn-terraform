provider "aws" {}

# vpc
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# subnet module
module "subnet_module" {
  source            = "./modules/subnet"
  vpc_id            = aws_vpc.myapp-vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone        = var.avail_zone
  env_prefix        = var.env_prefix
}

# webserver module
module "webserver_module" {
  source               = "./modules/webserver"
  vpc_id               = aws_vpc.myapp-vpc.id
  image_name           = var.image_name
  image_owner          = var.image_owner
  public_key_location  = var.public_key_location
  private_key_location = var.private_key_location
  instance_type        = var.instance_type
  subnet_id            = module.subnet_module.subnet_id
  avail_zone           = var.avail_zone
  env_prefix           = var.env_prefix
  my_ip                = var.my_ip
}
