data "ncloud_server_images" "all" {
  output_file = "server_images.json"
}

data "ncloud_server_products" "all" {
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  output_file               = "server_products.json"
}

# data "ncloud_nks_server_images" "all" {
  
#   output_file = "nks_server_images.json"
# }


