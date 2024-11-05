# bastion server spec
data "ncloud_server_image_numbers" "kvm-image" {
  server_image_name = var.server_image_name
  filter {
    name = "hypervisor_type"
    values = [var.hypervisor_type]
  }
}

data "ncloud_server_specs" "kvm-spec" {
  filter {
    name   = "server_spec_code"
    values = [var.server_spec_code]
  }
}

# NSK spec
data "ncloud_nks_versions" "version" {
  hypervisor_code = var.hypervisor_type
  filter {
    name = "value"
    values = [var.nks_version]   
    regex = true
  }
}

data "ncloud_nks_server_images" "image"{
  hypervisor_code = var.hypervisor_type
  filter {
    name = "label"
    values = [var.node_image]
    regex = true
  }
}

data "ncloud_nks_server_products" "product"{
  software_code = data.ncloud_nks_server_images.image.images[0].value
  zone = var.zone

  filter {
    name = "product_type"
    values = [var.node_product_type] 
  }

  filter {
    name = "cpu_count"
    values = [var.node_cpu_core]
  }

  filter {
    name = "memory_size"
    values = [var.node_memory_size]
  }
}