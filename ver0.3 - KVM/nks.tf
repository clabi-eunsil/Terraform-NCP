# NSK spec
data "ncloud_nks_versions" "version" {
  hypervisor_code = var.hypervisor_type
  filter {
    name   = "value"
    values = [var.nks_version]
    regex  = true
  }
}

data "ncloud_nks_server_images" "image" {
  hypervisor_code = var.hypervisor_type
  filter {
    name   = "label"
    values = [var.node_image]
    regex  = true
  }
}

data "ncloud_nks_server_products" "product" {
  software_code = data.ncloud_nks_server_images.image.images[0].value
  zone          = var.zone

  filter {
    name   = "product_type"
    values = [var.node_product_type]
  }

  filter {
    name   = "cpu_count"
    values = [var.node_cpu_core]
  }

  filter {
    name   = "memory_size"
    values = [var.node_memory_size]
  }
}

# NKS 구성
resource "ncloud_nks_cluster" "cluster" {
  hypervisor_code      = "KVM"
  cluster_type         = "SVR.VNKS.STAND.C002.M008.G003" # default
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
  cluster_uuid     = ncloud_nks_cluster.cluster.uuid
  node_pool_name   = "${var.service_name}-np"
  node_count       = var.node_count
  software_code    = data.ncloud_nks_server_images.image.images[0].value
  server_spec_code = data.ncloud_nks_server_products.product.products.0.value
  storage_size     = var.node_storage_size
  #   autoscale {             # 필요에 따라 활성화하여 node autoscaling 가능
  #     enabled = false
  #     min = 2
  #     max = 2
  #   }
}