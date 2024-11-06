# IAM 설정
site = "pub" # 민간 (공공은 "gov")
ncloud_access_key = ""
ncloud_secret_key = ""

# service 이름 설정
service_name = "tf-test"

# VPC 및 Subnet 설정
vpc_cidr     = "10.0.0.0/16"
pub_dmz_subnet_cidr = "10.0.1.0/24"
pub_lb_subnet_cidr = "10.0.5.0/24"
pub_nat_subnet_cidr = "10.0.6.0/24"
pri_svc_subnet_cidr = "10.0.11.0/24"
pri_lb_subnet_cidr = "10.0.15.0/24"
# pri_db_subnet_cidr = "10.0.21.0/24"  # 필요에 따라 사용

# Hypervisor 설정
hypervisor_type = "KVM" # default

# bastion 서버 설정
server_image_name = "ubuntu-22.04-base" # ex: rocky-8.10-base, ubuntu-20.04-base ...
server_spec_code = "c2-g3"  # ex: c4-g3, s2-g3, s4-g4 ...

bastion_init_script_path = "../source/sh/ubuntu-init.sh"
# client_ip = "1.209.x.x/32" # 다른 IP로 대치 가능

# NKS 설정
nks_version = 1.29 # ex: 1.28, 1.27 ...
# worker node 설정
node_image = "ubuntu-22.04" # default
node_count = 1  # worker node 갯수
node_product_type = "HICPU" # HICPU, STAND, HIMEM
node_cpu_core = "2" # default (product type에 따라 설정)
node_memory_size = "4GB" # default (product type에 따라 설정)
node_storage_size = 100 # default (100GB 이상)