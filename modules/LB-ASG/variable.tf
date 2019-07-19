variable "publicSubnet_id" {}
variable "ami"{
    default = "ami-0986c2ac728528ac2"
}
variable "privateSubnet_id" {}
variable "vpc_id" {}
variable "securityGroup_webapp_instances"{}
variable "DBSecurityGroup" {}
variable "securityGroup_webapp_albs" {}
variable "region"{
    default="us-east-2"
}
