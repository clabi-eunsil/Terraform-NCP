# PEM키 생성
resource "ncloud_login_key" "loginkey" {
  key_name = var.service_name
}

resource "local_file" "ssh_key" {
  filename = "./${ncloud_login_key.loginkey.key_name}.pem"
  content  = ncloud_login_key.loginkey.private_key
}

# ACG 생성
resource "ncloud_access_control_group" "bastion_acg" {
  name   = "${var.service_name}-bastion-acg"
  vpc_no = ncloud_vpc.vpc.id
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
  name   = "${var.service_name}-common-acg"
  vpc_no = ncloud_vpc.vpc.id
}

resource "ncloud_access_control_group_rule" "common_acg_rule" {
  access_control_group_no = ncloud_access_control_group.common_acg.id

  outbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = "1-65535"
  }
  outbound {
    protocol   = "UDP"
    ip_block   = "0.0.0.0/0"
    port_range = "1-65535"
  }
  outbound {
    protocol = "ICMP"
    ip_block = "0.0.0.0/0"
  }
}