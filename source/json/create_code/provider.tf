terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
      version = ">= 2.3.19"
    }
  }
}

provider "ncloud" {
  region      = "KR"
  site        = "pub" # 민간
  support_vpc = "true"

  access_key = ""
  secret_key = ""
}