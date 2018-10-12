/* Create a keypair to use for our instances */
resource "aws_key_pair" "two_tier_vpc_key" {
  key_name   = "${var.ServerKeyName}"
  public_key = "${file(var.ServerKeyNamePub)}"
}

/*
  Networking Section
*/
resource "aws_vpc" "main" {
  cidr_block = "${var.VPCCIDR}"

  tags = {
    "Application" = "${var.StackName}"
    "Network"     = "MGMT"
    "Name"        = "${var.VPCName}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.PublicCIDR_Block}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    "Application" = "${var.StackName}"
    "Name"        = "${join("", list(var.StackName, "_public_subnet"))}"
  }
}

resource "aws_subnet" "web_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.WebCIDR_Block}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    "Application" = "${var.StackName}"
    "Name"        = "${join("", list(var.StackName, "_web_subnet"))}"
  }
}

resource "aws_subnet" "db_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.DbCIDR_Block}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    "Application" = "${var.StackName}"
    "Name"        = "${join("", list(var.StackName, "_db_subnet"))}"
  }
}

resource "aws_network_acl" "aclb765d6d2" {
  vpc_id = "${aws_vpc.main.id}"

  subnet_ids = [
    "${aws_subnet.public_subnet.id}",
    "${aws_subnet.web_subnet.id}",
  ]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    "Name" = "${join("", list(var.StackName, "_public"))}"
  }
}

resource "aws_route_table" "web_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    "Name" = "${join("", list(var.StackName, "_web"))}"
  }
}

resource "aws_route_table" "db_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    "Name" = "${join("", list(var.StackName, "_db"))}"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "web_rt_association" {
  subnet_id      = "${aws_subnet.web_subnet.id}"
  route_table_id = "${aws_route_table.web_route_table.id}"
}

resource "aws_route_table_association" "db_rt_association" {
  subnet_id      = "${aws_subnet.db_subnet.id}"
  route_table_id = "${aws_route_table.db_route_table.id}"
}

resource "aws_route" "igw_route" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.InternetGateway.id}"
}

resource "aws_route" "web_route" {
  route_table_id         = "${aws_route_table.web_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = "${aws_network_interface.firewall_web_interface.id}"
}

resource "aws_route" "db_route" {
  route_table_id         = "${aws_route_table.db_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = "${aws_network_interface.firewall_db_interface.id}"
}

resource "aws_network_interface" "firewall_management_interface" {
  subnet_id         = "${aws_subnet.public_subnet.id}"
  security_groups   = ["${aws_security_group.management_security_group.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["10.0.0.99"]
}

resource "aws_network_interface" "firewall_public_interface" {
  subnet_id         = "${aws_subnet.public_subnet.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["10.0.0.100"]
}

resource "aws_network_interface" "firewall_web_interface" {
  subnet_id         = "${aws_subnet.web_subnet.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["10.0.1.11"]
}

resource "aws_network_interface" "firewall_db_interface" {
  subnet_id         = "${aws_subnet.db_subnet.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["10.0.2.11"]
}

resource "aws_network_interface" "WPNetworkInterface" {
  subnet_id         = "${aws_subnet.web_subnet.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["10.0.1.101"]
}

resource "aws_network_interface" "db_network_interface" {
  subnet_id         = "${aws_subnet.db_subnet.id}"
  security_groups   = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips       = ["10.0.2.101"]
}

resource "aws_eip" "PublicElasticIP" {
  vpc        = true
  depends_on = ["aws_vpc.main", "aws_internet_gateway.InternetGateway"]
}

resource "aws_eip" "ManagementElasticIP" {
  vpc        = true
  depends_on = ["aws_vpc.main", "aws_internet_gateway.InternetGateway"]
}

resource "aws_eip_association" "FWEIPManagementAssociation" {
  network_interface_id = "${aws_network_interface.firewall_management_interface.id}"
  allocation_id        = "${aws_eip.ManagementElasticIP.id}"
}

resource "aws_eip_association" "FWEIPPublicAssociation" {
  network_interface_id = "${aws_network_interface.firewall_public_interface.id}"
  allocation_id        = "${aws_eip.PublicElasticIP.id}"
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Application = "${var.StackName}"
    Network     = "MGMT"
    Name        = "${join("-", list(var.StackName, "InternetGateway"))}"
  }
}

/* Create S3 bucket for bootstrap files */
resource "aws_s3_bucket" "bootstrap_bucket" {
  bucket        = "${var.MasterS3Bucket}"
  acl           = "private"
  force_destroy = true

  tags {
    Name = "Bootstrap Bucket"
  }
}

/* Upload bootstrap files to the S3 Bucket above */
resource "aws_s3_bucket_object" "bootstrap_xml" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  acl    = "private"
  key    = "config/bootstrap.xml"
  source = "bootstrap_files/bootstrap.xml"
}

resource "aws_s3_bucket_object" "init-cft_txt" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  acl    = "private"
  key    = "config/init-cfg.txt"
  source = "bootstrap_files/init-cfg.txt"
}

resource "aws_s3_bucket_object" "software" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "license" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  acl    = "private"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "content" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  acl    = "private"
  key    = "content/"
  source = "bootstrap_files/panupv2-all-contents-8072-5053"
}

/* Roles, ACLs, Permissions, etc... */

resource "aws_iam_role" "FWBootstrapRole2Tier" {
  name = "FWBootstrapRole2Tier"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "FWBootstrapRolePolicy2Tier" {
  name = "FWBootstrapRolePolicy2Tier"
  role = "${aws_iam_role.FWBootstrapRole2Tier.id}"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.MasterS3Bucket}"
    },
    {
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${var.MasterS3Bucket}/*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "FWBootstrapInstanceProfile2Tier" {
  name = "FWBootstrapInstanceProfile2Tier"
  role = "${aws_iam_role.FWBootstrapRole2Tier.name}"
  path = "/"
}

resource "aws_network_acl_rule" "acl1" {
  network_acl_id = "${aws_network_acl.aclb765d6d2.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "acl2" {
  network_acl_id = "${aws_network_acl.aclb765d6d2.id}"
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_security_group" "sgWideOpen" {
  name        = "sgWideOpen"
  description = "Wide open security group"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "management_security_group" {
  name        = "management_security_group"
  description = "Allow admin access to managment interfaces"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Create the PAN Firewall instance */
resource "aws_instance" "FWInstance" {
  disable_api_termination              = false
  iam_instance_profile                 = "${aws_iam_instance_profile.FWBootstrapInstanceProfile2Tier.name}"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = "${var.PANFWRegionMap[var.aws_region]}"
  instance_type                        = "m4.xlarge"

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_type           = "gp2"
    delete_on_termination = true
    volume_size           = 60
  }

  key_name   = "${var.ServerKeyName}"
  monitoring = false

  lifecycle {
    ignore_changes = ["ebs_block_device"]
  }

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.firewall_management_interface.id}"
  }

  network_interface {
    device_index         = 1
    network_interface_id = "${aws_network_interface.firewall_public_interface.id}"
  }

  network_interface {
    device_index         = 2
    network_interface_id = "${aws_network_interface.firewall_web_interface.id}"
  }

  network_interface {
    device_index         = 3
    network_interface_id = "${aws_network_interface.firewall_db_interface.id}"
  }

  user_data = "${base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.MasterS3Bucket)))}"

  tags {
    "Name" = "${join("", list(var.StackName, "_PAN_Firewall"))}"
  }
}

/* Create the Ubuntu web server instance */
resource "aws_instance" "WPWebInstance" {
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  ami                                  = "${var.UbuntuRegionMap[var.aws_region]}"
  instance_type                        = "t2.micro"

  key_name   = "${var.ServerKeyName}"
  monitoring = false

  network_interface {
    #delete_on_termination = true
    device_index         = 0
    network_interface_id = "${aws_network_interface.WPNetworkInterface.id}"
  }

  user_data = "${base64encode(join("", list(
  "#! /bin/bash\n",

          "exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1\n",

          "while true\n",
          "  do\n",
          "   resp=$(curl -s -S -g --insecure \"https://${aws_eip.ManagementElasticIP.public_ip}/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0=\")\n",
          "   echo $resp >> /tmp/pan.log\n",
          "   if [[ $resp == *\"[CDATA[yes\"* ]] ; then\n",
          "     break\n",
          "   fi\n",
          "  sleep 10s\n",
          "done\n",
          "apt-get update\n",
          "apt-get install -y apache2 wordpress\n"
  )))
  }"

  tags {
    "Name" = "${join("", list(var.StackName, "_Web_Server"))}"
  }
}

/* Create the Ubuntu DB server instance */
resource "aws_instance" "DBInstance" {
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  ami                                  = "${var.UbuntuRegionMap[var.aws_region]}"
  instance_type                        = "t2.micro"

  key_name   = "${var.ServerKeyName}"
  monitoring = false

  network_interface {
    #delete_on_termination = true
    device_index         = 0
    network_interface_id = "${aws_network_interface.db_network_interface.id}"
  }

  user_data = "${base64encode(join("", list(
  "#! /bin/bash\n",

          "exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1\n",

          "while true\n",
          "  do\n",
          "   resp=$(curl -s -S -g --insecure \"https://${aws_eip.ManagementElasticIP.public_ip}/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT11U3g4RWdZREtKaW55NWFXSVJtMW5VQ0ZzVHc9SzFwOEhaQ29Sd1BYaGZxK3hwa1RUbkZodXVQNFVHZmZhdWg0cFpxb2RmZz0=\")\n",
          "   echo $resp >> /tmp/pan.log\n",
          "   if [[ $resp == *\"[CDATA[yes\"* ]] ; then\n",
          "     break\n",
          "   fi\n",
          "  sleep 10s\n",
          "done\n",
          "apt-get update\n",
          "apt-get install -y mysql-common mysql-server\n"
  )))
  }"

  tags {
    "Name" = "${join("", list(var.StackName, "_DB_Server"))}"
  }
}

resource "aws_route53_record" "gpawsdemo" {
  zone_id = "${var.aws_route53_zone}"
  name    = "gpawsdemo.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.PublicElasticIP.public_ip}"]
}

output "FirewallManagementURL" {
  value = "${join("", list("https://", "${aws_eip.ManagementElasticIP.public_ip}"))}"
}

output "WebURL" {
  value = "${join("", list("http://", "${aws_eip.PublicElasticIP.public_ip}"))}"
}
