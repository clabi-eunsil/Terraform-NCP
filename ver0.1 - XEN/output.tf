output "bastion_ip" {
  description = "Public IP of the bastion server"
  value       = ncloud_public_ip.pub_ip.public_ip
}

output "vpc_id" {
  value = ncloud_vpc.vpc.id
}

output "nks_cluster_uuid" {
  value = ncloud_nks_cluster.cluster.uuid
}

output "nks_node_pool_id" {
  value = ncloud_nks_node_pool.node_pool.id
}
