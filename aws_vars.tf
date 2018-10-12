data "aws_availability_zones" "available" {}
variable "aws_region" {}
variable "WebCIDR_Block" {}
variable "PublicCIDR_Block" {}
variable "DbCIDR_Block" {}
variable "MasterS3Bucket" {}
variable "VPCName" {}
variable "VPCCIDR" {}
variable "ServerKeyName" {}
variable "ServerKeyNamePub" {}
variable "StackName" {}
variable "aws_route53_zone" {}

variable "PANFWRegionMap" {
  type = "map"

  default = {
    "us-east-1"      = "ami-bffd3cc2"
    "us-east-2"      = "ami-9ef3c5fb"
    "us-west-1"      = "ami-854551e5"
    "us-west-2"      = "ami-9a29b8e2"
    "sa-east-1"      = "ami-d80653b4"
    "eu-west-1"      = "ami-1fb1ff66"
    "eu-west-2"      = "ami-c4688fa3"
    "eu-central-1"   = "ami-1ebdd571"
    "ca-central-1"   = "ami-57048333"
    "ap-northeast-1" = "ami-75652e13"
    "ap-northeast-2" = "ami-a8bf13c6"
    "ap-southeast-1" = "ami-36bdec4a"
    "ap-southeast-2" = "ami-add013cf"
    "ap-south-1"     = "ami-ee80d981"
  }
}

variable "WebServerRegionMap" {
  type = "map"

  default = {
    "us-east-1"      = "ami-1ecae776"
    "us-east-2"      = "ami-c55673a0"
    "us-west-2"      = "ami-e7527ed7"
    "us-west-1"      = "ami-d114f295"
    "eu-west-1"      = "ami-a10897d6"
    "eu-central-1"   = "ami-a8221fb5"
    "ap-northeast-1" = "ami-cbf90ecb"
    "ap-southeast-1" = "ami-68d8e93a"
    "ap-southeast-2" = "ami-fd9cecc7"
    "sa-east-1"      = "ami-b52890a8"
    "cn-north-1"     = "ami-f239abcb"
  }
}

variable "UbuntuRegionMap" {
  type = "map"

  default = {
    "us-west-2"      = "ami-efd0428f"
    "ap-northeast-1" = "ami-afb09dc8"
    "us-west-1"      = "ami-2afbde4a"
    "ap-northeast-2" = "ami-66e33108"
    "ap-southeast-1" = "ami-8fcc75ec"
    "ap-southeast-2" = "ami-96666ff5"
    "eu-central-1"   = "ami-060cde69"
    "eu-west-1"      = "ami-a8d2d7ce"
    "eu-west-2"      = "ami-f1d7c395"
    "sa-east-1"      = "ami-4090f22c"
    "us-east-1"      = "ami-80861296"
    "us-east-2"      = "ami-618fab04"
    "ca-central-1"   = "ami-b3d965d7"
    "ap-south-1"     = "ami-c2ee9dad"
  }
}
