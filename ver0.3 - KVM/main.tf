provider "ncloud" {
  region      = var.region
  site        = var.site
  support_vpc = "true"
  access_key  = var.ncloud_access_key
  secret_key  = var.ncloud_secret_key
}