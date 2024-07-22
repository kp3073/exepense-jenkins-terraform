module "vpc" {
  source                     = "./modules/vpc"
  vpc_cidr                   = var.vpc_cidr
  env                        = var.env
  public_subnet              = var.public_subnet
  private_subnet             = var.private_subnet
  azs                        = var.azs
  default_vpc_id             = var.default_vpc_id
  account_no                 = var.account_no
  default_vpc_cidr           = var.default_vpc_cidr
  default_vpc_route_table_id = var.default_vpc_route_table_id
}

module "public_alb" {
  source        = "./modules/alb"
  env           = var.env
  alb_type      = "public"
  internal      = false
  vpc_id        = module.vpc.vpc_id
  allow_sg_cidr = "0.0.0.0/0"
  subnet        = module.vpc.public_subnet
  dns_name      = "${var.env}.aligntune.online"
  zone_id       = "Z03008653NMBFHGJP7YNJ"
  tg_arn        = module.frontend.tg_arm
}

module "private_alb" {
  source        = "./modules/alb"
  env           = var.env
  alb_type      = "private"
  internal      = true
  vpc_id        = module.vpc.vpc_id
  allow_sg_cidr = var.vpc_cidr
  subnet        = module.vpc.private_subnet
  dns_name      = "backend-${var.env}.aligntune.online"
  zone_id       = "Z03008653NMBFHGJP7YNJ"
  tg_arn        = module.backend.tg_arm
}

module "frontend" {
  source            = "./modules/app"
  app_port          = 80
  component         = "frontend"
  env               = var.env
  instance_type     = "t3.small"
  vpc_cidr          = var.vpc_cidr
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.private_subnet
  bastion_node_cidr = var.bastion_node_cidr
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity

}


  module "backend" {
  depends_on        = [module.mysql]
  source            = "./modules/app"
  app_port          = 8080
  component         = "backend"
  env               = var.env
  instance_type     = "t3.small"
  vpc_cidr          = var.vpc_cidr
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.private_subnet
  bastion_node_cidr = var.bastion_node_cidr
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
}

module "mysql" {
  source    = "./modules/rds"
  vpc_cidr  = var.vpc_cidr
  component = "mysql"
  env       = var.env
  subnets   = module.vpc.private_subnet
  vpc_id    = module.vpc.vpc_id
}