variable "ncloud_access_key" {
  description = "Naver Cloud Platform Access Key"
  type        = string
  sensitive   = true  # 민감 정보로 표시
}

variable "ncloud_secret_key" {
  description = "Naver Cloud Platform Secret Key"
  type        = string
  sensitive   = true  # 민감 정보로 표시
}

variable "region" {
  description = "Region to deploy resources in Ncloud"
  type        = string
  default     = "KR"  # 기본값을 설정했지만 필요에 따라 변경 가능
}

variable "site" {
  description = "Ncloud Site"
  type        = string
  default     = "public"  # pub | gov | fin
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "KR-1"
}

variable "service_name" {
  description = "The name of the service for naming the resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# 각 서브넷의 CIDR을 변수로 정의
variable "pub_dmz_subnet_cidr" {
  description = "CIDR block for the public DMZ subnet"
  type        = string
}

variable "pub_lb_subnet_cidr" {
  description = "CIDR block for the public Load Balancer subnet"
  type        = string
}

variable "pub_nat_subnet_cidr" {
  description = "CIDR block for the public NAT subnet"
  type        = string
}

variable "pri_svc_subnet_cidr" {
  description = "CIDR block for the private Service subnet"
  type        = string
}

variable "pri_lb_subnet_cidr" {
  description = "CIDR block for the private Load Balancer subnet"
  type        = string
}

variable "pri_db_subnet_cidr" {
  description = "CIDR block for the private Database subnet"
  type        = string
  default     = null  # Optional if a DB subnet is not always needed
}


variable "bastion_init_script_path" {
  description = "Path to the local init script file"
  type        = string
}

variable "client_ip" {
  description = "Inbound IP blocks to allow for the Bastion server"
  type        = string
  default     = "1.209.229.248/32" #clabi
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "node_storage_size" {
  description = "Default storage size for KVM nodepool. (Default 100GB)"
  type        = number
  default     = 100
}