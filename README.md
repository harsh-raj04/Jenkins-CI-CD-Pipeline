# Simple AWS EC2 with Terraform

Learn Terraform by launching a basic EC2 instance on AWS - super simple!

## 📋 What This Does

Launches 1 Ubuntu server on AWS with:
- **Nginx web server** installed automatically
- **SSH access** to connect to your server
- **Simple website** saying "Hello from Terraform!"

## 📁 Files (Only 3!)

```
networking.tf    # Creates VPC, subnet, firewall
compute.tf       # Creates EC2 instance
variables.tf     # Your settings
```

## 🚀 Quick Start

### Step 1: Prerequisites

1. **AWS Account** - [Sign up](https://aws.amazon.com)
2. **Install Terraform** - [Download](https://www.terraform.io/downloads)
3. **AWS CLI** configured:
   ```bash
   aws configure
   ```
4. **Create SSH Key** in AWS Console:
   - Go to EC2 → Key Pairs → Create Key Pair
   - Save the `.pem` file

### Step 2: Configure

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit it (only change key_name!)
nano terraform.tfvars
```

Change this line:
```hcl
key_name = "your-key-name"    # Put your AWS key name here
```

### Step 3: Deploy

```bash
terraform init       # Download AWS provider
terraform plan       # See what will be created
terraform apply      # Create it! (type 'yes')
```

**Done!** In 2 minutes you'll see:
```
instance_ip = "3.123.45.67"
website_url = "http://3.123.45.67"
ssh_command = "ssh -i your-key.pem ubuntu@3.123.45.67"
```

## 🌐 Test It

1. **View Website**: Open `website_url` in browser
2. **SSH into Server**: Use the `ssh_command` shown

## 📖 Understanding Each File

### `networking.tf` - Network Setup
```
What it does:
1. Creates a VPC (your private network)
2. Creates a subnet (part of the network)
3. Creates internet gateway (connects to internet)
4. Creates security group (firewall rules)
```

### `compute.tf` - The Server
```
What it does:
1. Finds latest Ubuntu image
2. Launches EC2 instance
3. Installs Nginx web server
4. Creates a simple webpage
```

### `variables.tf` - Your Settings
```
What you can change:
- aws_region: Where to launch (us-east-1, eu-west-1, etc.)
- instance_type: Server size (t2.micro is FREE!)
- key_name: Your SSH key
- allowed_cidr: Who can SSH in
```

## 💰 Cost

- **t2.micro** = FREE (750 hours/month for 1 year)
- After free tier: ~$8/month

## 🛠️ Useful Commands

```bash
# See outputs again
terraform output

# SSH into your server
ssh -i your-key.pem ubuntu@<ip-address>

# Destroy everything (delete all resources)
terraform destroy
```

## 🔧 Common Issues

**"Invalid credentials"**
```bash
aws configure    # Enter your AWS access keys
```

**"Key pair not found"**
- Make sure key_name in terraform.tfvars matches AWS key name exactly

**"Permission denied (publickey)"**
```bash
chmod 400 your-key.pem    # Fix key permissions
```

**Can't access website?**
- Wait 2-3 minutes for Nginx to install
- Check security group allows port 80

## 🎓 What You're Learning

1. **Infrastructure as Code** - Define infrastructure in files
2. **AWS Basics** - VPC, subnets, security groups, EC2
3. **Terraform Workflow** - init → plan → apply → destroy
4. **Resource Dependencies** - How resources connect

## 🧹 Cleanup

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
