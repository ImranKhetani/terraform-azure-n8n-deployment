# 🧩 terraform-azure-n8n-deployment

Automated deployment of **n8n**, the open-source workflow automation tool, on **Microsoft Azure** using **Terraform** and **cloud-init**.

This repository provisions a fully functional n8n instance running in Docker on an Ubuntu VM, fronted by **Nginx** with **SSL (Let's Encrypt)**, and accessible through a public DNS endpoint.

---

## 🚀 Features

- ✅ One-command deployment with Terraform  
- 🐳 n8n running in Docker with persistent volume  
- 🌐 Nginx reverse proxy with HTTPS (via Let’s Encrypt Certbot)  
- 🔒 Azure NSG rules for SSH, HTTP, HTTPS, and n8n ports  
- ⚙️ Automatic domain name and DNS assignment through Azure Public IP  
- 🕓 Configured for **Asia/Kolkata** timezone  

---

## 🧱 Architecture Overview

```
Azure Resource Group
├── Virtual Network (VNet)
│   └── Subnet
│       └── Network Security Group (NSG)
│           ├── Allow SSH (22)
│           ├── Allow HTTP (80)
│           ├── Allow HTTPS (443)
│           └── Allow n8n (5678)
├── Public IP (with FQDN)
├── Network Interface (NIC)
└── Linux Virtual Machine (Ubuntu 22.04)
    ├── Docker + n8n container
    ├── Nginx reverse proxy
    └── Certbot (Let's Encrypt SSL)
```

---

## 📁 Repository Structure

```bash
terraform-azure-n8n-deployment/
├── main.tf              # Main Terraform configuration for Azure resources
├── cloud-init.yaml      # Cloud-init script to configure VM and deploy n8n
├── outputs.tf           # Terraform output definitions
└── README.md            # Documentation
```

---

## ⚙️ Prerequisites

Before you begin, make sure you have:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ v1.3 installed  
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in (`az login`)  
- SSH key pair generated and available locally (`~/.ssh/id_rsa.pub`)  
- Permissions to create Azure resources (VMs, Networking, etc.)  

---

## 🧩 Configuration

### 1. Clone the repository

```bash
git clone https://github.com/ImranKhetani/terraform-azure-n8n-deployment.git
cd terraform-azure-n8n-deployment
```

### 2. Update `main.tf`

Replace the placeholder with your Azure subscription ID:

```hcl
subscription_id = "your-azure-subscription-id"
```

### 3. (Optional) Update domain/email in `cloud-init.yaml`

- **Domain:** Update `server_name` in the Nginx block to your desired domain/subdomain.  
- **Email:** Update the email in the `certbot` command for SSL certificate registration.

---

## 🏗️ Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Preview the changes

```bash
terraform plan
```

### 3. Apply and deploy

```bash
terraform apply -auto-approve
```

Terraform will:
- Create all Azure resources  
- Provision the VM  
- Run `cloud-init` to install Docker, deploy n8n, configure Nginx, and issue an SSL certificate  

---

## 🌐 Accessing Your n8n Instance

After successful deployment, Terraform outputs the public DNS name:

```bash
Outputs:

n8n_dns_name = "<endpoint>"
```

Visit:

```
https://<endpoint that you have used>
```

Your n8n dashboard should load over HTTPS.  
(Default port 5678 is proxied internally via Nginx.)

---

## 🧹 Cleanup

To destroy all Azure resources created by this deployment:

```bash
terraform destroy -auto-approve
```

---

## 🛠️ Troubleshooting

- **SSL not issued?**  
  Ensure port 80 and 443 are open in the NSG and the domain name resolves to the VM’s public IP.

- **n8n not accessible?**  
  SSH into the VM and check Docker and Nginx status:
  ```bash
  sudo docker ps
  sudo systemctl status nginx
  sudo tail -f /var/log/cloud-init-output.log
  ```

- **Changing the region or VM size:**  
  Modify the corresponding fields in `main.tf` (e.g., `location` or `size`).

---

## 🧑‍💻 Author

**Imran Khetani**  
📧 [khetaniimran@gmail.com](mailto:khetaniimran@gmail.com)

---

## 📜 License

This project is licensed under the [MIT License](LICENSE) — feel free to use, modify, and distribute.

---

## ⭐ Contribute

If you find this project helpful:
- Star the repo ⭐  
- Fork and improve it 🔧  
- Open issues or pull requests 💬  
