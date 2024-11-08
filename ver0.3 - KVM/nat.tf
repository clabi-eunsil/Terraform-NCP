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