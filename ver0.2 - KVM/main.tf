# VPC 설정
resource "ncloud_vpc" "vpc" {
  name            = "${var.service_name}-vpc"
  ipv4_cidr_block = var.vpc_cidr
}

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
  count = var.pri_db_subnet_cidr != null ? 1 : 0
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = var.pri_db_subnet_cidr
  zone           = var.zone
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "${var.service_name}-pri-db-sub"
  usage_type     = "GEN"
}

# NAT 설정
resource "ncloud_nat_gateway" "nat_gw" {
  vpc_no    = ncloud_vpc.vpc.id
  subnet_no = ncloud_subnet.pub_nat_subnet.id
  zone      = var.zone
  name      = "${var.service_name}-nat-gw"
}

resource "ncloud_route_table" "private_route_table" {
  vpc_no                = ncloud_vpc.vpc.id
  supported_subnet_type = "PRIVATE"
  name                  = "${var.service_name}-route-table"
}

resource "ncloud_route" "route" {
  route_table_no         = ncloud_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW"
  target_name            = ncloud_nat_gateway.nat_gw.name
  target_no              = ncloud_nat_gateway.nat_gw.id
}

resource "ncloud_route_table_association" "private_route_table_subnet" {
  route_table_no = ncloud_route_table.private_route_table.id
  subnet_no      = ncloud_subnet.pri_svc_subnet.id
}

# PEM키 생성
resource "ncloud_login_key" "loginkey" {
  key_name  = "${var.service_name}"
}

resource "local_file" "ssh_key" {
  filename  = "./${ncloud_login_key.loginkey.key_name}.pem"
  content   = ncloud_login_key.loginkey.private_key
}

# ACG 생성 (현재 NIC을 신규 생성하지 않는 경우에는, 콘솔에서 수동으로 ACG를 변경해주어야 함)
resource "ncloud_access_control_group" "bastion_acg" {
  name      = "${var.service_name}-bastion-acg"
  vpc_no    = ncloud_vpc.vpc.id
}

resource "ncloud_access_control_group_rule" "bastion_acg_rule" {
  access_control_group_no = ncloud_access_control_group.bastion_acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = var.client_ip
    port_range  = "22"
    description = "clabi"
  }
}

resource "ncloud_access_control_group" "common_acg" {
  name      = "${var.service_name}-common-acg"
  vpc_no    = ncloud_vpc.vpc.id
}

resource "ncloud_access_control_group_rule" "common_acg_rule" {
  access_control_group_no = ncloud_access_control_group.common_acg.id

  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
  }
  outbound {
    protocol    = "UDP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
  }
  outbound {
    protocol    = "ICMP"
    ip_block    = "0.0.0.0/0"
  }
}

# Bastion 서버 설정
resource "ncloud_init_script" "init_script" {
  name      = "${var.service_name}-init-script"
  content   = file(var.bastion_init_script_path) 
}

resource "ncloud_server" "bastion" {
  name                          = "${var.service_name}-bastion"
  subnet_no                     = ncloud_subnet.pub_dmz_subnet.id
  zone                          = var.zone
  login_key_name                = ncloud_login_key.loginkey.key_name
  is_protect_server_termination = false
  server_image_number           = data.ncloud_server_image_numbers.kvm-image.image_number_list.0.server_image_number
  server_spec_code              = data.ncloud_server_specs.kvm-spec.server_spec_list.0.server_spec_code
  init_script_no                = ncloud_init_script.init_script.id
}

resource "ncloud_public_ip" "pub_ip" {
  server_instance_no   = ncloud_server.bastion.id
}

# NKS 구성
resource "ncloud_nks_cluster" "cluster" {
  hypervisor_code      = "KVM"
  cluster_type         = "SVR.VNKS.STAND.C002.M008.G003"      # default
  k8s_version          = data.ncloud_nks_versions.version.versions.0.value
  login_key_name       = ncloud_login_key.loginkey.key_name
  name                 = "${var.service_name}-cluster"
  lb_private_subnet_no = ncloud_subnet.pri_lb_subnet.id
  lb_public_subnet_no  = ncloud_subnet.pub_lb_subnet.id
  kube_network_plugin  = "cilium"
  subnet_no_list       = [ncloud_subnet.pri_svc_subnet.id]
  vpc_no               = ncloud_vpc.vpc.id
  public_network       = false
  zone                 = var.zone
}

resource "ncloud_nks_node_pool" "node_pool" {
  cluster_uuid      = ncloud_nks_cluster.cluster.uuid
  node_pool_name    = "${var.service_name}-np"
  node_count        = var.node_count
  software_code     = data.ncloud_nks_server_images.image.images[0].value
  server_spec_code  = data.ncloud_nks_server_products.product.products.0.value
  storage_size      = var.node_storage_size
#   autoscale {             # 필요에 따라 활성화하여 node autoscaling 가능
#     enabled = false
#     min = 2
#     max = 2
#   }
}