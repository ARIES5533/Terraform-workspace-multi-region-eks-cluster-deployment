

module "moses_vpc" {
    source = "./modules/vpc"
}


module "my-eks" {
    source = "./modules/eks"

    vpc_id                 = module.moses_vpc.vpc_id
    vpc_private_subnets    = module.moses_vpc.vpc_private_subnets
    vpc_public_subnets    = module.moses_vpc.vpc_public_subnets

} 


module "moses_rds" {
  source = "./modules/rds" # Path to your RDS module
  

  
  db_subnet_group_name = module.moses_vpc.db_subnet_group_name
  
  db_security_group_id = module.moses_vpc.db_security_group_id

}