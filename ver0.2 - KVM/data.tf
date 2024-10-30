# bastion server spec
data "ncloud_server_image_numbers" "kvm-image" {
  server_image_name = "ubuntu-22.04-base"   # 원하는 image 이름으로 변경 가능
  filter {
    name = "hypervisor_type"
    values = ["KVM"]
  }
}

data "ncloud_server_specs" "kvm-spec" {
  filter {
    name   = "server_spec_code"
    values = ["c2-g3"]      # 2core 4mem
  }
}

# NSK spec
data "ncloud_nks_versions" "version" {
  hypervisor_code = "KVM"
  filter {
    name = "value"
    values = ["1.29"]   # 원하는 version으로 변경 가능
    regex = true
  }
}

data "ncloud_nks_server_images" "image"{
  hypervisor_code = "KVM"
  filter {
    name = "label"
    values = ["ubuntu-22.04"]
    regex = true
  }
}

data "ncloud_nks_server_products" "product"{
  software_code = data.ncloud_nks_server_images.image.images[0].value
  zone = var.zone

  filter {
    name = "product_type"
    values = [ "HICPU"]             # HICPU | STAND | HIMEM | etc..
  }

  filter {
    name = "cpu_count"
    values = [ "2"]
  }

  filter {
    name = "memory_size"
    values = [ "4GB" ]
  }
}