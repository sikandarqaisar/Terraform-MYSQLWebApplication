output "DBSecurityGroup" {
    value = "${aws_security_group.sgdb.id}"
}
output "securityGroup_webapp_albs" {
    value = "${aws_security_group.webapp_albs.id}"
}
output "securityGroup_webapp_instances" {
    value = "${aws_security_group.webapp_instances.id}"
}
output "vpc_id" {
    value = "${aws_vpc.default.id}"
}

output "publicSubnet_id" {
    value = "${aws_subnet.public-subnet.id}"
}
output "privateSubnet_id" {
    value = "${aws_subnet.private-subnet.id}"
}
