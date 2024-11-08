# bastion server spec
data "ncloud_server_image_numbers" "kvm-image" {
  server_image_name = var.server_image_name
  filter {
    name   = "hypervisor_type"
    values = [var.hypervisor_type]
  }
}

data "ncloud_server_specs" "kvm-spec" {
  filter {
    name   = "server_spec_code"
    values = [var.server_spec_code]
  }
}

# Bastion 서버 설정
resource "ncloud_init_script" "init_script" {
  name = "${var.service_name}-init-script"
  content = templatefile(var.bastion_init_script_tpl, {
    ncp_access_key = var.ncloud_access_key,
    ncp_secret_key = var.ncloud_secret_key,
    environment    = var.site,
    cluster_uuid   = ncloud_nks_cluster.cluster.uuid
  })

  depends_on = [ncloud_nks_cluster.cluster]

  lifecycle {
    ignore_changes = [content]
  }
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

  depends_on = [ncloud_nks_cluster.cluster,
  ncloud_init_script.init_script]
}

resource "ncloud_public_ip" "pub_ip" {
  server_instance_no = ncloud_server.bastion.id
}
