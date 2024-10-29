
data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${terraform.workspace}-olumoko"
}


######### Create VPC #####################
module "olumoko_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "olumoko-${terraform.workspace}-vpc"
  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3) # Corrected reference

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  
  enable_dns_hostnames = true
  enable_nat_gateway = true
  create_igw = true 

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

output "vpc_id" {
  description = "The ID of the primary VPC"
  value       = module.olumoko_vpc.vpc_id
}

output "vpc_public_subnets" {
  description = "The public subnet IDs of the primary VPC"
  value       = module.olumoko_vpc.public_subnets
}

output "vpc_private_subnets" {
  description = "The private subnet IDs of the primary VPC"
  value       = module.olumoko_vpc.private_subnets
}


##########Define the primary RDS subnet group in the eu-west-1 region#########
resource "aws_db_subnet_group" "olumoko-subnet" {
  name        = "${terraform.workspace}-db-subnet-group"
  description = "Subnet group for RDS instance"
  #subnet_ids  = module.olumoko_vpc.private_subnets
  subnet_ids  = concat(module.olumoko_vpc.private_subnets, module.olumoko_vpc.public_subnets)


  tags = {
    Name = "Olumoko-${terraform.workspace}-DB-Subnet-Group"
  }
}


output "db_subnet_group_name" {
  description = "The name of the database subnet group."
  value       = aws_db_subnet_group.olumoko-subnet.name
}

output "vpc_db_subnet_group_id" {
  description = "The name of the primary database subnet group."
  value       = aws_db_subnet_group.olumoko-subnet.id
}


##############


############## Create Security Group #######################
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"


  name = "olumoko-${terraform.workspace}-sg"
  description = "Security group"
  vpc_id = module.olumoko_vpc.vpc_id

    ingress_with_cidr_blocks = [
      {
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       description = "Allow outbound HTTPS traffic"
       cidr_blocks = "10.0.0.0/16"
      },
      {
       from_port   = 80
       to_port     = 80
       protocol    = "tcp"
       description = "Allow outbound HTTP traffic"
       cidr_blocks = "10.0.0.0/16"
      }
    ]

    egress_with_cidr_blocks = [
      {
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       description = "Allow outbound HTTPS traffic"
       cidr_blocks = "0.0.0.0/0"
      },
      {
       from_port   = 80
       to_port     = 80
       protocol    = "tcp"
       description = "Allow outbound HTTP traffic"
       cidr_blocks = "0.0.0.0/0"
      }
    ]

    depends_on = [module.olumoko_vpc]

    tags = {
        name = "olumoko-${terraform.workspace}-sg"
    }
       
}

output "sg_id" {
  description = "The ID of the primary security group"
  value       = module.security-group.security_group_id
}

##########Create Security Group for DB ####################

module "security-group-db" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name = "olumoko-${terraform.workspace}-sg-db"
  description = "Allow traffic on PostgreSQL port 5432"
  vpc_id = module.olumoko_vpc.vpc_id

    ingress_with_cidr_blocks = [
      {
       from_port   = 5432
       to_port     = 5432
       protocol    = "tcp"
       description = "Allow inbound traffic on PostgreSQL port 5432"
       cidr_blocks = "10.0.0.0/16"
      }
    ]

    egress_with_cidr_blocks = [
      {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       description = "Allow outbound traffic on PostgreSQL port 5432"
       cidr_blocks = "10.0.0.0/16"
      }
    ]

    depends_on = [module.olumoko_vpc]

    tags = {
        name = "olumoko-${terraform.workspace}-sg-db"
    }
       
}

output "db_security_group_id" {
  description = "The ID of the RDS security group"
  value       = module.security-group-db.security_group_id
}