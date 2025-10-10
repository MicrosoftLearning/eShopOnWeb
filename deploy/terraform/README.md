# Terraform Infrastructure as Code

This directory contains Terraform configurations for deploying the eShopOnWeb application infrastructure on Azure.

## Overview

The Terraform configuration provisions:
- **Azure Kubernetes Service (AKS)** cluster
- **Azure Container Registry (ACR)** for container images
- **Virtual Network** with subnets
- **Network Security Groups** for security
- **Storage Account** for persistent data
- **Role Assignments** for AKS to ACR integration

## Architecture

```
deploy/terraform/
├── main.tf                    # Main configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example variables file
├── modules/                   # Reusable modules
│   ├── aks/                   # AKS cluster module
│   ├── networking/            # VNet and networking module
│   └── storage/               # Storage account module
└── environments/              # Environment-specific configs
    ├── dev/
    ├── staging/
    └── production/
```

## Prerequisites

1. **Install Terraform** (>= 1.0)
   ```bash
   # macOS
   brew install terraform

   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/

   # Windows
   choco install terraform
   ```

2. **Install Azure CLI**
   ```bash
   # macOS
   brew install azure-cli

   # Linux
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

   # Windows
   choco install azure-cli
   ```

3. **Authenticate to Azure**
   ```bash
   az login
   az account set --subscription "<subscription-id>"
   ```

4. **Configure Service Principal (Optional, for CI/CD)**
   ```bash
   az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/<subscription-id>"
   ```

## Quick Start

### 1. Initialize Terraform

```bash
cd deploy/terraform
terraform init
```

This will:
- Download required provider plugins (Azure, Random)
- Initialize the backend
- Set up module dependencies

### 2. Create Variables File

Copy the example file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Plan the Deployment

Review what will be created:

```bash
terraform plan
```

### 4. Apply the Configuration

Deploy the infrastructure:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 5. Get Outputs

After deployment, retrieve important information:

```bash
# View all outputs
terraform output

# Get specific output
terraform output aks_cluster_name
terraform output acr_login_server

# Get kubeconfig (sensitive)
terraform output -raw aks_kube_config > ~/.kube/config-eshoponweb
```

## Environment-Specific Deployments

### Development

```bash
terraform init
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### Staging

```bash
terraform init
terraform plan -var-file="environments/staging/terraform.tfvars"
terraform apply -var-file="environments/staging/terraform.tfvars"
```

### Production

```bash
terraform init
terraform plan -var-file="environments/production/terraform.tfvars"
terraform apply -var-file="environments/production/terraform.tfvars"
```

## Configuration Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `resource_group_name` | Name of the resource group | `rg-eshoponweb` |
| `location` | Azure region | `East US` |
| `environment` | Environment name | `dev`, `staging`, `production` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `cluster_name` | AKS cluster name | `aks-eshoponweb` |
| `kubernetes_version` | K8s version | `1.28` |
| `node_count` | Initial node count | `2` |
| `vm_size` | VM size for nodes | `Standard_D2s_v3` |
| `enable_auto_scaling` | Enable autoscaling | `true` |
| `min_node_count` | Min nodes (autoscaling) | `2` |
| `max_node_count` | Max nodes (autoscaling) | `5` |
| `acr_sku` | ACR SKU | `Basic` |

See `variables.tf` for complete list.

## Remote State Configuration

For team collaboration, configure remote state in Azure Storage:

### 1. Create Storage Account for State

```bash
# Set variables
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="tfstate$(openssl rand -hex 4)"
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME
```

### 2. Configure Backend in main.tf

Uncomment and update the backend configuration:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatexxxxxxxx"
    container_name       = "tfstate"
    key                  = "eshoponweb.terraform.tfstate"
  }
}
```

### 3. Re-initialize

```bash
terraform init -migrate-state
```

## Connecting to AKS Cluster

After deployment, connect to your AKS cluster:

```bash
# Get credentials
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw aks_cluster_name)

# Verify connection
kubectl get nodes

# View cluster info
kubectl cluster-info
```

## Deploying Application to AKS

After infrastructure is provisioned:

1. **Build and push images to ACR**
   ```bash
   ACR_NAME=$(terraform output -raw acr_name)
   az acr login --name $ACR_NAME

   # Build and push from repository root
   docker build -t $ACR_NAME.azurecr.io/eshopwebmvc:latest -f src/Web/Dockerfile .
   docker build -t $ACR_NAME.azurecr.io/eshoppublicapi:latest -f src/PublicApi/Dockerfile .

   docker push $ACR_NAME.azurecr.io/eshopwebmvc:latest
   docker push $ACR_NAME.azurecr.io/eshoppublicapi:latest
   ```

2. **Deploy Kubernetes manifests**
   ```bash
   cd ../k8s
   
   # Update kustomization.yaml with ACR name
   # Then apply
   kubectl apply -k .
   ```

## Module Documentation

### AKS Module (`modules/aks/`)

Creates Azure Kubernetes Service cluster with:
- System-assigned managed identity
- Azure CNI networking
- Autoscaling support
- Virtual Machine Scale Sets

### Networking Module (`modules/networking/`)

Creates networking resources:
- Virtual Network
- Subnets (AKS, Gateway)
- Network Security Groups
- Security rules for HTTP/HTTPS

### Storage Module (`modules/storage/`)

Creates storage resources:
- Storage Account
- Blob Container
- Versioning enabled

## Outputs

After `terraform apply`, you'll get:

- `resource_group_name`: Resource group name
- `aks_cluster_name`: AKS cluster name
- `aks_cluster_fqdn`: Cluster FQDN
- `acr_login_server`: ACR login server URL
- `acr_name`: ACR name
- `vnet_id`: Virtual network ID
- `storage_account_name`: Storage account name

Sensitive outputs (kubeconfig, storage keys) require `-raw` flag.

## Managing Infrastructure

### View Current State

```bash
# List resources
terraform state list

# Show resource details
terraform state show azurerm_kubernetes_cluster.aks
```

### Update Infrastructure

Modify variables or configuration, then:

```bash
terraform plan
terraform apply
```

### Destroy Infrastructure

⚠️ **Warning**: This will delete all resources!

```bash
terraform destroy
```

For specific environments:

```bash
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

## Cost Optimization

### Development
- Use `Standard_B2s` VMs
- Disable autoscaling
- Use Basic ACR SKU
- 1-2 nodes

### Staging
- Use `Standard_D2s_v3` VMs
- Enable autoscaling (2-4 nodes)
- Use Standard ACR SKU

### Production
- Use `Standard_D4s_v3` or larger
- Enable autoscaling (3-10 nodes)
- Use Premium ACR SKU
- Consider reserved instances

## Troubleshooting

### Terraform Init Fails

```bash
# Clear cache and re-initialize
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Authentication Errors

```bash
# Re-login to Azure
az login
az account show
```

### State Lock Issues

```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

### Provider Version Conflicts

```bash
# Upgrade providers
terraform init -upgrade
```

## Security Best Practices

1. **Use Remote State**: Store state in Azure Storage with encryption
2. **Enable RBAC**: Use Azure AD for authentication
3. **Network Policies**: Implement network policies in AKS
4. **Secrets Management**: Use Azure Key Vault for secrets
5. **Private Endpoints**: Use private AKS cluster in production
6. **Audit Logging**: Enable Azure Monitor and logging
7. **Regular Updates**: Keep Kubernetes version updated

## CI/CD Integration

### Azure DevOps

```yaml
- task: TerraformInstaller@0
  inputs:
    terraformVersion: '1.6.0'

- task: TerraformTaskV4@4
  inputs:
    command: 'init'
    workingDirectory: '$(System.DefaultWorkingDirectory)/deploy/terraform'
    backendServiceArm: 'Azure-Connection'
    backendAzureRmResourceGroupName: 'rg-terraform-state'
    backendAzureRmStorageAccountName: 'tfstate'
    backendAzureRmContainerName: 'tfstate'
    backendAzureRmKey: 'terraform.tfstate'

- task: TerraformTaskV4@4
  inputs:
    command: 'apply'
    workingDirectory: '$(System.DefaultWorkingDirectory)/deploy/terraform'
    environmentServiceNameAzureRM: 'Azure-Connection'
```

### GitHub Actions

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v2
  with:
    terraform_version: 1.6.0

- name: Terraform Init
  run: terraform init
  working-directory: ./deploy/terraform

- name: Terraform Plan
  run: terraform plan
  working-directory: ./deploy/terraform

- name: Terraform Apply
  run: terraform apply -auto-approve
  working-directory: ./deploy/terraform
```

## Validation

Validate configuration before applying:

```bash
# Validate syntax
terraform validate

# Format code
terraform fmt -recursive

# Check for security issues (requires tfsec)
tfsec .
```

## Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/azure/aks/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)

## Support

For issues or questions:
1. Check Terraform and Azure CLI versions
2. Review Azure subscription limits
3. Check Azure service health
4. Review Terraform state for conflicts
