resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true 
   tags ={
        Name = "${var.name_prefix}-webapp"
    }
}

resource "aws_subnet" "public-subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-east-2a"

    tags = {
        Name = "${var.name_prefix}-public"
    }
}
resource "aws_subnet" "private-subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "us-east-2b"

    tags = {
         Name = "${var.name_prefix}-privateSubnet"
    }
}
resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.default.id}"
    tags = {
        Name = "${var.name_prefix}-WebhApp"
    }
}   
resource "aws_route_table" "web-public-rt" {
    vpc_id = "${aws_vpc.default.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
    tags = {
        Name = "${var.name_prefix}-webapp"
    }
}
resource "aws_route_table_association" "web-public-rt"  {
    subnet_id = "${aws_subnet.public-subnet.id}"
    route_table_id = "${aws_route_table.web-public-rt.id}"
} 

 resource "aws_route_table" "nat_gw_1" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_1.id}"
  }

  tags = {
    Name = "Application to Internet through Nat #1"
  }
}
resource "aws_route_table_association" "app_1_subnet_to_nat_gw" {
  route_table_id = "${aws_route_table.nat_gw_1.id}"
  subnet_id      = "${aws_subnet.private-subnet.id}"
}


resource "aws_eip" "nat_1" {
}
resource "aws_nat_gateway" "nat_1" {
  allocation_id = "${aws_eip.nat_1.id}"
  subnet_id = "${aws_subnet.public-subnet.id}"
}










 
resource "aws_security_group" "sgdb" {
  name         = "sikandar-sg_test_web"
  description  = "My VPC Security Group"
     vpc_id = "${aws_vpc.default.id}"
   tags = {
       Name = "${var.name_prefix}-webapp"
   }
}

 
resource "aws_security_group_rule" "inboundmysql"{
    type = "ingress"
    source_security_group_id = "${aws_security_group.webapp_instances.id}"
    security_group_id = "${aws_security_group.sgdb.id}" 
    from_port   = 3306
    to_port     = 3360
    protocol    = "tcp"
  }
resource "aws_security_group_rule" "inboundAll"{
       type = "ingress"
           security_group_id = "${aws_security_group.sgdb.id}" 
    source_security_group_id = "${aws_security_group.webapp_instances.id}"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
  }
resource "aws_security_group_rule" "inboundssh"{
        type = "ingress"
            security_group_id = "${aws_security_group.sgdb.id}" 
    source_security_group_id = "${aws_security_group.webapp_instances.id}"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  resource "aws_security_group_rule" "outbound" {
        security_group_id = "${aws_security_group.sgdb.id}" 
    type = "egress"
    cidr_blocks = ["0.0.0.0/0"]  
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }






















//SecurityGroup
resource "aws_security_group" "webapp_albs" {
    name = "${var.name_prefix}-webapp-albs"
    vpc_id = "${aws_vpc.default.id}"
    description = "Security group for ALBs"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags ={
        Name = "${var.name_prefix}-webapp"
    }
}

resource "aws_security_group" "webapp_instances" {
    name = "${var.name_prefix}-webapp-instances"
    vpc_id = "${aws_vpc.default.id}"
    description = "Security group for instances"

    tags ={
        Name = "${var.name_prefix}-webapp"
    }
}

resource "aws_security_group_rule" "allow_all_egress" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.webapp_instances.id}"
}


resource "aws_security_group_rule" "allow_all_from_albs" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.webapp_instances.id}"
    source_security_group_id = "${aws_security_group.webapp_albs.id}"
}


resource "aws_security_group_rule" "allow_ssh_from_internet" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.webapp_instances.id}"
}
