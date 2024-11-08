# VPC 설정
resource "ncloud_vpc" "vpc" {
  name            = "${var.service_name}-vpc"
  ipv4_cidr_block = var.vpc_cidr
}
