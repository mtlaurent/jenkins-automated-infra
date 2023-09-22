erraform {
        required_providers {
                aws = {
                        source  = "hashicorp/aws"
                }
        }
}
provider "aws" {
        region = "us-east-1"
}
# VPC
resource "aws_vpc" "INFRANAME-VPC" {
        cidr_block = "10.0.0.0/16"
        tags = {
                Name = "INFRANAME-VPC"
        }
}
# SUBNET PUBLIC
resource "aws_subnet" "INFRANAME-SUBNET-PUBLIC" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        cidr_block = "10.0.1.0/24"
        tags = {
                Name = "INFRANAME-SUBNET-PUBLIC"
        }
}
# SUBNET PRIVATE
resource "aws_subnet" "INFRANAME-SUBNET-AZ-A" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        cidr_block = "10.0.2.0/24"
        availability_zone = "us-east-1a"
        tags = {
                Name = "INFRANAME-SUBNET-AZ-A"
        }
}

resource "aws_subnet" "INFRANAME-SUBNET-AZ-B" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        cidr_block = "10.0.3.0/24"
        availability_zone = "us-east-1b"
        tags = {
                Name = "INFRANAME-SUBNET-AZ-B"
        }
}
resource "aws_subnet" "INFRANAME-SUBNET-AZ-C" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        cidr_block = "10.0.4.0/24"
        availability_zone = "us-east-1c"
        tags = {
                Name = "INFRANAME-SUBNET-AZ-C"
        }
}
# GATEWAY
resource "aws_internet_gateway" "INFRANAME-IGW" {
        tags = {
                Name = "INFRANAME-IGW"
        }
}
# ATTACHE GW
resource "aws_internet_gateway_attachment" "INFRANAME-IGW-ATTACH" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.INFRANAME-IGW.id}"
}
# ROUTE
resource "aws_route_table" "INFRANAME-RTB-PUBLIC" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.INFRANAME-IGW.id}"
        }
        tags = {
                Name = "INFRANAME-RTB-PUBLIC"
        }
}
# ROUTE TABLES
resource "aws_route_table_association" "INFRANAME-RTB-PUBLIC-ASSOC1" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-A.id}"
        route_table_id = "${aws_route_table.INFRANAME-RTB-PUBLIC.id}"
}
resource "aws_route_table_association" "INFRANAME-RTB-PUBLIC-ASSOC2" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-B.id}"
        route_table_id = "${aws_route_table.INFRANAME-RTB-PUBLIC.id}"
}
resource "aws_route_table_association" "INFRANAME-RTB-PUBLIC-ASSOC3" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-C.id}"
        route_table_id = "${aws_route_table.INFRANAME-RTB-PUBLIC.id}"
}
resource "aws_route_table_association" "INFRANAME-RTB-PUBLIC-ASSOC" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-PUBLIC.id}"
        route_table_id = "${aws_route_table.INFRANAME-RTB-PUBLIC.id}"
}
# SECURITY GROUPS
resource "aws_security_group" "INFRANAME-SG-SQUID-PUBLIC" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
         ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                from_port = "3128"
                to_port = "3128"
                protocol = "tcp"
                security_groups = ["${aws_security_group.INFRANAME-SG-WEB.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "INFRANAME-SG-SQUID-PUBLIC"
        }
}

# HAPROXY LB
resource "aws_security_group" "INFRANAME-SG-LOAD-BALANCER" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "INFRANAME-SG-LOAD-BALANCER"
        }
}
resource "aws_security_group" "INFRANAME-SG-WEB" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                security_groups = ["${aws_security_group.INFRANAME-SG-LOAD-BALANCER.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "INFRANAME-SG-PUBLIC"
        }
}
resource "aws_security_group" "INFRANAME-SG-ADMIN" {
        vpc_id = "${aws_vpc.INFRANAME-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "INFRANAME-SG-ADMIN"
        }
}
# INSTANCE
resource "aws_instance" "INFRANAME-INSTANCE-SQUID-PUBLIC" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-SQUID-PUBLIC.id}"]
        associate_public_ip_address = true
        user_data = file("squid.sh")
        tags = {
                Name = "INFRANAME-INSTANCE-PUBLIC"
        }
}
resource "aws_instance" "INFRANAME-INSTANCE-AZ-A" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-A.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.INFRANAME-INSTANCE-SQUID-PUBLIC.private_ip}" })}"
        tags = {
                Name = "INFRANAME-INSTANCE-AZ-A"
        }
}
resource "aws_instance" "INFRANAME-INSTANCE-AZ-B" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-B.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.INFRANAME-INSTANCE-SQUID-PUBLIC.private_ip}" })}"
        tags = {
                Name = "INFRANAME-INSTANCE-AZ-B"
        }
}
resource "aws_instance" "INFRANAME-INSTANCE-AZ-C" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-AZ-C.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.INFRANAME-INSTANCE-SQUID-PUBLIC.private_ip}" })}"
        tags = {
                Name = "INFRANAME-INSTANCE-AZ-C"
        }
}
# DATA
data "template_file" "config_haproxy" {
        template = "${file("rproxy.tpl")}"
        vars = {
                WEB_IP_A = "${aws_instance.INFRANAME-INSTANCE-AZ-A.private_ip}"
                WEB_IP_B = "${aws_instance.INFRANAME-INSTANCE-AZ-B.private_ip}"
                WEB_IP_C = "${aws_instance.INFRANAME-INSTANCE-AZ-C.private_ip}"
        }
}
# HAPROXY
resource "aws_instance" "INFRANAME-INSTANCE-HAPROXY" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-LOAD-BALANCER.id}", "${aws_security_group.INFRANAME-SG-ADMIN.id}"]
        associate_public_ip_address = true
        user_data = "${data.template_file.config_haproxy.rendered}"
        tags = {
                Name = "INFRANAME-INSTANCE-HAPROXY"
        }
}
# MACHINE ADMIN
resource "aws_instance" "INFRANAME-INSTANCE-ADMIN" {
        subnet_id = "${aws_subnet.INFRANAME-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-04cb4ca688797756f"
        key_name = "vockey"
        vpc_security_group_ids = ["${aws_security_group.INFRANAME-SG-ADMIN.id}"]
        associate_public_ip_address = true
        user_data = file("AdminMachine.sh")
        tags = {
                Name = "INFRANAME-INSTANCE-ADMIN"
        }
}