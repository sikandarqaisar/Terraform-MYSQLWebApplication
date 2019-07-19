provider "aws"{
    region ="us-east-2"
}
module "vpc"{
    source = "./modules/vpc"
    name_prefix="${var.name_prefix}"
}
module "LB-ASG"{
    source = "./modules/LB-ASG"
    DBSecurityGroup =  "${module.vpc.DBSecurityGroup}"
    securityGroup_webapp_albs  = "${module.vpc.securityGroup_webapp_albs}"
    securityGroup_webapp_instances= "${module.vpc.securityGroup_webapp_instances}"
    vpc_id=  "${module.vpc.vpc_id}"
    publicSubnet_id = "${module.vpc.publicSubnet_id}"
    privateSubnet_id = "${module.vpc.privateSubnet_id}"
    }
