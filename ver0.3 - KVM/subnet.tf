# 서브넷 설정
resource "ncloud_subnet" "pub_dmz_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = var.pub_dmz_subnet_cidr
  zone           = var.zone
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "${var.service_name}-pub-dmz-sub"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "pub_lb_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = var.pub_lb_subnet_cidr
  zone           = var.zone
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "${var.service_name}-pub-lb-sub"
  usage_type     = "LOADB"
}

resource "ncloud_subnet" "pub_nat_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = var.pub_nat_subnet_cidr
  zone           = var.zone
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "${var.service_name}-nat-sub"
  usage_type     = "NATGW"
}

resource "ncloud_subnet" "pri_svc_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = var.pri_svc_subnet_cidr
  zone           = var.zone
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "${var.service_name}-pri-svc-sub"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "pri_lb_subnet" {
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = var.pri_lb_subnet_cidr
  zone           = var.zone
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "${var.service_name}-pri-lb-sub"
  usage_type     = "LOADB"
}

# Optional: Private Database Subnet
resource "ncloud_subnet" "pri_db_subnet" {
  count          = var.pri_db_subnet_cidr != null ? 1 : 0
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = var.pri_db_subnet_cidr
  zone           = var.zone
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "${var.service_name}-pri-db-sub"
  usage_type     = "GEN"
}