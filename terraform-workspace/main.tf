

module "moses_vpc" {
    source = "./modules/vpc"
}



module "my-eks" {
    source = "./modules/eks"

    vpc_primary_id                 = module.moses_vpc.vpc_primary_id
    vpc_primary_private_subnets    = module.moses_vpc.vpc_primary_private_subnets
} 