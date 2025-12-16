# ============================================
# LOCAL FILE OUTPUTS
# ============================================
# Persistent Ansible inventory file for AWS hosts
# This file is NOT deleted on terraform destroy
# ============================================

# Null resource to manage persistent inventory file
resource "null_resource" "update_inventory" {
  # Trigger on any instance changes
  triggers = {
    instance_ips = join(",", [for instance in aws_instance.web : instance.public_ip])
    instance_ids = join(",", [for instance in aws_instance.web : instance.id])
  }

  # Add new instances to inventory
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      # Create aws_hosts file if it doesn't exist
      if [ ! -f ../playbooks/aws_hosts ]; then
        echo "[all]" > ../playbooks/aws_hosts
      fi
      
      # Add new IPs to aws_hosts if not already present
      %{for key, instance in aws_instance.web~}
      if ! grep -q "${instance.public_ip}" ../playbooks/aws_hosts 2>/dev/null; then
        echo "${instance.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=../devops.pem # ${instance.tags["Name"]} - ${instance.availability_zone}" >> ../playbooks/aws_hosts
      fi
      %{endfor~}
    EOT
  }

  # Remove only destroyed instances from inventory
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      # Remove IPs from aws_hosts when instances are destroyed
      if [ -f ../playbooks/aws_hosts ]; then
        %{for ip in split(",", self.triggers.instance_ips)~}
        sed -i '' '/^${ip} /d' ../playbooks/aws_hosts
        %{endfor~}
      fi
    EOT
  }

  depends_on = [aws_instance.web]
}
