
module "vpc" {
    source = "./Modulus/VPC"

    VPC_Name = "Main VPC"
    cidr_block = "10.0.0.0/16"

    public_subnets = ["10.0.0.0/24","10.0.1.0/24"]
    azs_public = ["us-east-1a","us-east-1b"]
    private_subnets =["10.0.2.0/24","10.0.3.0/24"]
    azs_private = ["us-east-1a","us-east-1b"]
    one_nat_gateway_per_az = true
    enable_nat_gateway = true
    single_nat_gateway = false
}
