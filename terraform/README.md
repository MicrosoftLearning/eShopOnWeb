# eShopOnWeb Terraform Deployment

This directory contains Terraform configuration files for deploying the eShopOnWeb application infrastructure to Microsoft Azure.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v1.0 or later
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) configured with appropriate permissions
- An Azure subscription

## Authentication

Authenticate with Azure using the Azure CLI:

```bash
az login
az account set --subscription "your-subscription-id"
```

Alternatively, you can use service principal authentication by setting environment variables:

```bash
export ARM_CLIENT_ID="your-service-principal-app-id"
export ARM_CLIENT_SECRET="your-service-principal-password"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

## Configuration

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and provide the required values:
   ```hcl
   environment_name = "dev"
   location = "East US"
   sql_admin_password = "YourSecurePassword123!"
   app_user_password = "YourAppUserPassword123!"
   ```

3. (Optional) Customize resource names and other settings as needed.

## Deployment

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the execution plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Confirm the deployment by typing `yes` when prompted.

## What Gets Deployed

This Terraform configuration creates the following Azure resources:

### Core Infrastructure
- **Resource Group**: Container for all resources
- **App Service Plan**: Linux-based plan for hosting the web application
- **Key Vault**: Secure storage for connection strings and passwords

### Database
- **SQL Server**: Two separate servers for catalog and identity databases
- **SQL Databases**: Catalog and Identity databases
- **Firewall Rules**: Allow Azure services to access the databases

### Application
- **Linux Web App**: Hosts the eShopOnWeb application
- **Managed Identity**: System-assigned identity for Key Vault access
- **App Settings**: Configuration including Key Vault references

### Security
- **Key Vault Secrets**: Connection strings and passwords
- **Access Policies**: Web app access to Key Vault secrets

## Application Deployment

After the infrastructure is deployed, you need to deploy the application code:

1. Build and publish the application:
   ```bash
   dotnet publish src/Web/Web.csproj -c Release -o ./publish
   ```

2. Create a deployment package:
   ```bash
   cd publish
   zip -r ../deploy.zip .
   cd ..
   ```

3. Deploy using Azure CLI:
   ```bash
   az webapp deployment source config-zip \
     --resource-group $(terraform output -raw resource_group_name) \
     --name $(terraform output -raw web_app_name) \
     --src deploy.zip
   ```

Alternatively, you can use GitHub Actions, Azure DevOps, or other CI/CD tools for automated deployment.

## Accessing the Application

After deployment, the application will be available at:
```bash
terraform output web_app_url
```

## Configuration Options

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `environment_name` | Environment name for resource naming | `dev` | No |
| `location` | Azure region for resources | `East US` | No |
| `sql_admin_password` | SQL Server admin password | - | Yes |
| `app_user_password` | Application user password | - | Yes |
| `resource_group_name` | Custom resource group name | Auto-generated | No |
| `web_service_name` | Custom web app name | Auto-generated | No |
| `principal_id` | Object ID for Key Vault access | - | No |

### Customization

You can customize the deployment by:

1. Modifying variables in `terraform.tfvars`
2. Updating resource configurations in `main.tf`
3. Adding additional resources as needed

## Outputs

After deployment, Terraform provides the following outputs:

- `resource_group_name`: Name of the created resource group
- `web_app_name`: Name of the web application
- `web_app_url`: URL to access the application
- `key_vault_name`: Name of the Key Vault
- `catalog_database_server_name`: Name of the catalog database server
- `identity_database_server_name`: Name of the identity database server

## Scaling and Production Considerations

For production deployments, consider:

1. **App Service Plan**: Upgrade from Basic (B1) to Standard or Premium for better performance and features
2. **Database**: Use higher service tiers for better performance
3. **Monitoring**: Add Application Insights for monitoring and diagnostics
4. **Security**: Implement network security groups and private endpoints
5. **Backup**: Configure automated backups for databases
6. **SSL**: Use custom domains with SSL certificates

Example production modifications in `main.tf`:

```hcl
# Upgrade App Service Plan
resource "azurerm_service_plan" "main" {
  # ... other settings
  sku_name = "S1"  # Standard tier
}

# Add Application Insights
resource "azurerm_application_insights" "main" {
  name                = "ai-${local.resource_token}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  tags                = local.tags
}
```

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources. Ensure you have backups if needed.

## Troubleshooting

### Common Issues

1. **Authentication errors**: Ensure you're logged in to Azure CLI or have correct service principal credentials
2. **Permission errors**: Verify your account has Contributor access to the subscription
3. **Name conflicts**: Resource names must be globally unique (especially Key Vault and Web App names)
4. **SQL password requirements**: Ensure passwords meet Azure SQL complexity requirements

### Debugging

Enable Terraform debugging:
```bash
export TF_LOG=DEBUG
terraform apply
```

Check Azure resource status:
```bash
az group show --name $(terraform output -raw resource_group_name)
```

## Integration with Bicep

This Terraform configuration provides similar functionality to the existing Bicep templates in the `infra/` directory. You can choose either approach based on your preferences:

- **Bicep**: Native Azure resource manager templates
- **Terraform**: Multi-cloud infrastructure as code with broader ecosystem

Both approaches create similar infrastructure with the same application compatibility.