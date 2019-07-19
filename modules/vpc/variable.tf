provider "aws"{
    region="us-east-2"
}
variable "aws_region"  {
    default="us-east-2"
}
variable "name_prefix"{}
variable "ami"{
    default = "ami-0986c2ac728528ac2"
}
variable "region"{
    default="us-east-2"
}
variable "vpc_cidr"{
    default = "10.0.0.0/16"
}
variable "private_subnet_cidr"{
    default="10.0.1.0/24"
}
variable "public_subnet_cidr"{
    default="10.0.0.0/24"
}
