# IAM 설정
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

# bastion 서버 설정
bastion_init_script_path = "../source/sh/ubuntu-init.sh"
client_ip = "0.0.0.0/0" # 다른 IP로 대치 가능

# worker node 갯수
node_count = 1