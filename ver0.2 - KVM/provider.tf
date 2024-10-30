terraform {
  required_providers {
    ncloud    = {
      source  = "NaverCloudPlatform/ncloud"
      version = ">= 2.3.19"
    }
  }
}

provider "ncloud" {
  region      = var.region
  site        = var.site
  support_vpc = "true"
  access_key  = var.ncloud_access_key
  secret_key  = var.ncloud_secret_key
}