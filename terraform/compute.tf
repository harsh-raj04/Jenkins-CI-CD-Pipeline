# ============================================
# EC2 INSTANCE
# ============================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }

  filter {
    name   = "location"
    values = data.aws_availability_zones.available.names
  }

  location_type = "availability-zone"
}

locals {
  supported_zones = toset(data.aws_ec2_instance_type_offerings.available.locations)
  zones_to_use    = slice(sort(tolist(local.supported_zones)), 0, min(var.instance_count, length(local.supported_zones)))
}

resource "aws_instance" "web" {
  for_each = { for idx, subnet in aws_subnet.public : idx => subnet if contains(local.zones_to_use, subnet.availability_zone) }

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = each.value.id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "${var.project_name}-server-${each.key + 1}"
    Zone = each.value.availability_zone
  }
}

resource "null_resource" "grafana_provisioner" {
  for_each = aws_instance.web

  depends_on = [aws_instance.web]

  triggers = {
    instance_id = each.value.id
  }

  connection {
    type        = "ssh"
    host        = each.value.public_ip
    user        = "ubuntu"
    private_key = file("${var.key_name}.pem")
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo connection test successful to ${each.value.public_ip}",
    ]
  }

  provisioner "local-exec" {
    # Run both playbooks from the project playbooks directory. Use absolute paths built from path.module
    command     = <<EOT
${"${path.module}"}/../playbooks/grafana-run.sh
EOT
    interpreter = ["bash", "-c"]
    working_dir = path.module
    environment = {
      PATH = "/opt/homebrew/bin:/usr/local/bin"
    }
  }
}
