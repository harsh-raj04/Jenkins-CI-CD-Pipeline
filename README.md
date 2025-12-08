# Jenkins CI/CD Pipeline for Terraform + Ansible

Automated deployment of EC2 instances with Grafana and Prometheus using Jenkins, Terraform, and Ansible.

## 📋 What This Does

Automatically deploys AWS infrastructure with monitoring stack:
- **EC2 instances** across multiple availability zones
- **Grafana** for visualization (port 3000)
- **Prometheus** for metrics collection (port 9090)
- **Automated provisioning** via Jenkins pipeline on git push

## 📁 Project Structure

```
.
├── Jenkinsfile                 # Jenkins pipeline definition
├── terraform/
│   ├── compute.tf             # EC2 instances
│   ├── networking.tf          # VPC, subnets, security groups
│   ├── variables.tf           # Input variables
│   ├── terraform.tfvars       # Variable values
│   ├── outputs.tf             # Output definitions
│   └── local_files.tf         # Ansible inventory management
├── playbooks/
│   ├── ansible.cfg            # Ansible configuration
│   ├── aws_hosts              # Dynamic inventory (auto-generated)
│   ├── grafana.yaml           # Grafana installation playbook
│   └── install-prometheus.yaml # Prometheus installation playbook
└── README.md
```

## 🚀 Jenkins Pipeline Setup

### Prerequisites
- Jenkins with Git, Pipeline plugins
- Terraform and Ansible installed on Jenkins server
- AWS credentials configured
- SSH key (`devops.pem`) in `~/.ssh/` on Jenkins server

### Step 1: Create Pipeline Job

1. In Jenkins, click **New Item**
2. Enter name: `terraform-ansible-pipeline`
3. Select **Pipeline** → OK

### Step 2: Configure Pipeline

**Build Triggers:**
- ✅ Check "GitHub hook trigger for GITScm polling"

**Pipeline Section:**
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/harsh-raj04/Jenkins-CI-CD-Pipeline`
- Branch: `*/main`
- Script Path: `Jenkinsfile`

### Step 3: Setup GitHub Webhook (Auto-trigger)

1. Go to GitHub repo → **Settings** → **Webhooks** → **Add webhook**
2. Payload URL: `http://<jenkins-url>/github-webhook/`
3. Content type: `application/json`
4. Events: "Just the push event"
5. Click **Add webhook**

### Step 4: Setup SSH Key

```bash
# Copy AWS SSH key to Jenkins server
cp /path/to/devops.pem ~/.ssh/devops.pem
chmod 600 ~/.ssh/devops.pem
```

## 🔄 Pipeline Workflow

1. **Push code** to GitHub
2. **GitHub webhook** triggers Jenkins
3. **Jenkins** runs pipeline:
   - Checkout code
   - Setup SSH key
   - Terraform init/plan/apply
   - Ansible provisions Grafana & Prometheus
4. **Services deployed** and accessible

## 📊 Access Deployed Services

After successful deployment:
- **Grafana**: `http://<instance-ip>:3000` (admin/admin)
- **Prometheus**: `http://<instance-ip>:9090`

Get IPs from Jenkins console output or:
```bash
cd terraform
terraform output instance_details
```

## 🔧 Configuration

**Change instance count:**
```hcl
# terraform/terraform.tfvars
instance_count = 1  # Increase to deploy more
```

**Change AWS region:**
```hcl
# terraform/terraform.tfvars
aws_region = "us-east-1"
```

## 🧹 Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```

## 🐛 Troubleshooting

**Pipeline fails with SSH errors:**
- Ensure `devops.pem` in `~/.ssh/` on Jenkins server
- Check permissions: `chmod 600 ~/.ssh/devops.pem`

**Ansible apt lock errors:**
- Wait 2-3 minutes and retry (cloud-init may be running)
- Playbooks now auto-wait for locks to clear

**Can't access Grafana/Prometheus:**
- Verify security group allows ports 3000, 9090
- Check instance status: `terraform output instance_details`

## 📝 Notes

- Pipeline uses `|| true` to continue if one playbook fails
- Ansible inventory auto-managed by Terraform
- SSH key excluded from git (`.gitignore`)

**IMPORTANT**: Delete everything when done to avoid charges:
```bash
terraform destroy    # Type 'yes' to confirm
```

## 📚 Next Steps

Once comfortable, try:
1. Change instance_type to `t2.small`
2. Add more security group rules
3. Deploy multiple instances
4. Add a load balancer

## 💡 Tips

- Always run `terraform plan` before `apply`
- Keep your `.pem` key file safe
- Use `terraform fmt` to format code nicely
- Read comments in the `.tf` files

---

**New to Terraform?** This is the perfect starting point! Each file has comments explaining what's happening.
# test
