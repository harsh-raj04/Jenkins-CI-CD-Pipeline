# ============================================
# OUTPUTS
# ============================================

output "instance_count" {
  description = "Number of instances created"
  value       = length(aws_instance.web)
}

output "all_instance_ips" {
  description = "All public IP addresses"
  value       = [for instance in aws_instance.web : instance.public_ip]
}

output "all_zones" {
  description = "All availability zones used"
  value       = [for instance in aws_instance.web : instance.availability_zone]
}

output "instance_details" {
  description = "Details of all instances"
  value = [
    for key, instance in aws_instance.web : {
      name = instance.tags["Name"]
      zone = instance.availability_zone
      ip   = instance.public_ip
      url  = "http://${instance.public_ip}"
      ssh  = "ssh -i ${var.key_name}.pem ubuntu@${instance.public_ip}"
    }
  ]
}
