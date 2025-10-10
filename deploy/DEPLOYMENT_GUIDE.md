# eShopOnWeb Deployment Guide

This guide provides an overview of the available deployment options for eShopOnWeb.

## Available Deployment Options

### 1. Kubernetes (Container Orchestration)
- **Location**: `/deploy/k8s/`
- **Use Case**: Production-grade container orchestration across multiple cloud providers
- **Features**:
  - Multiple deployment manifests (Web, PublicAPI)
  - ConfigMaps and Secrets for configuration
  - Service definitions (LoadBalancer, ClusterIP)
  - Ingress configuration for external access
  - Kustomize support for environment-specific overrides
  - Support for AKS, EKS, GKE, and on-premises clusters

**Quick Start**:
```bash
cd deploy/k8s
kubectl apply -k .
```

📖 [Full Kubernetes Documentation](k8s/README.md)

---

### 2. Terraform (Infrastructure as Code)
- **Location**: `/deploy/terraform/`
- **Use Case**: Automated infrastructure provisioning on Azure
- **Features**:
  - Azure Kubernetes Service (AKS) cluster provisioning
  - Azure Container Registry (ACR) setup
  - Virtual Network and networking components
  - Storage Account provisioning
  - Modular design (aks, networking, storage)
  - Environment-specific configurations (dev, staging, production)

**Quick Start**:
```bash
cd deploy/terraform
terraform init
terraform apply
```

📖 [Full Terraform Documentation](terraform/README.md)

---

### 3. Azure Bicep (Azure-Specific IaC)
- **Location**: `/infra/`
- **Use Case**: Azure-specific infrastructure deployment
- **Features**:
  - Azure App Service deployment
  - Azure Container Instances (ACI)
  - Azure SQL Database
  - Key Vault integration
  - Azure Developer CLI (azd) support

**Quick Start**:
```bash
azd init
azd up
```

📖 See main [README.md](../README.md) for Bicep/azd documentation

---

### 4. Docker Compose (Local Development)
- **Location**: Repository root (`docker-compose.yml`)
- **Use Case**: Local development and testing
- **Features**:
  - Multi-container setup (Web, PublicAPI, SQL Server)
  - Quick local environment setup
  - Easy debugging

**Quick Start**:
```bash
docker-compose build
docker-compose up
```

📖 See main [README.md](../README.md) for Docker documentation

---

## Deployment Decision Matrix

| Criteria | Kubernetes | Terraform | Bicep/azd | Docker Compose |
|----------|-----------|-----------|-----------|----------------|
| **Complexity** | Medium-High | Medium | Low-Medium | Low |
| **Cloud Agnostic** | ✅ Yes | ⚠️ Azure-focused | ❌ Azure only | ✅ Yes |
| **Production Ready** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ Dev only |
| **Auto-scaling** | ✅ Built-in | ✅ Via AKS | ✅ Via App Service | ❌ No |
| **Best For** | Multi-cloud, K8s expertise | Azure infra automation | Quick Azure deploy | Local dev/test |

---

## Recommended Deployment Paths

### Path 1: Quick Azure Deployment (Fastest)
1. Use **azd** with Bicep templates
2. Deploy to Azure App Service or ACI
3. Best for: Demos, POCs, simple deployments

### Path 2: Production Kubernetes (Most Flexible)
1. Use **Terraform** to provision AKS cluster and infrastructure
2. Use **Kubernetes manifests** to deploy applications
3. Best for: Production workloads, multi-cloud, scaling needs

### Path 3: Azure Kubernetes (Balanced)
1. Use **Terraform** to provision complete Azure infrastructure
2. Automatically connects AKS with ACR
3. Deploy apps using **Kubernetes manifests**
4. Best for: Azure-centric production deployments

### Path 4: Local Development (Simplest)
1. Use **Docker Compose** for local environment
2. Fast iteration and debugging
3. Best for: Development and testing

---

## Prerequisites by Deployment Type

### Kubernetes Deployment
- [ ] Kubernetes cluster (AKS, EKS, GKE, etc.)
- [ ] `kubectl` CLI installed
- [ ] Container registry access
- [ ] Docker for building images

### Terraform Deployment
- [ ] Azure subscription
- [ ] Terraform CLI (>= 1.0)
- [ ] Azure CLI
- [ ] Appropriate Azure permissions

### Bicep/azd Deployment
- [ ] Azure subscription
- [ ] Azure Developer CLI (`azd`)
- [ ] Azure CLI (optional)

### Docker Compose
- [ ] Docker Engine
- [ ] Docker Compose
- [ ] Sufficient local resources

---

## Environment Configuration

### Development
- Lower resource allocation
- In-memory database option
- Single replica deployments
- Basic SKU services

### Staging
- Production-like configuration
- Persistent storage
- Auto-scaling enabled
- Standard SKU services

### Production
- High availability setup
- Multi-replica deployments
- Auto-scaling configured
- Premium SKU services
- Monitoring and logging
- Backup and disaster recovery

---

## Security Considerations

### All Deployments
- ✅ Use secrets management (Key Vault, K8s Secrets)
- ✅ Never commit credentials to source control
- ✅ Use managed identities where possible
- ✅ Enable HTTPS/TLS
- ✅ Implement network policies
- ✅ Regular security updates

### Kubernetes Specific
- Use Network Policies
- Implement Pod Security Standards
- Use RBAC for access control
- Scan container images
- Use private container registries

### Terraform Specific
- Use remote state with encryption
- Implement state locking
- Use workspaces for environments
- Validate configurations before apply

---

## Monitoring and Observability

### Kubernetes
- Prometheus + Grafana
- Azure Monitor for AKS
- Application Insights
- Kubernetes Dashboard

### Azure (Bicep/Terraform)
- Azure Monitor
- Application Insights
- Log Analytics
- Azure Advisor

---

## Cost Optimization

### Development
- Use smaller VM sizes (B-series)
- Stop resources when not in use
- Use Azure Dev/Test subscriptions
- Disable auto-scaling

### Production
- Right-size VMs based on load
- Use reserved instances
- Implement auto-scaling
- Use Azure Cost Management
- Set up budget alerts

---

## Troubleshooting

### Common Issues

1. **Container Image Pull Errors**
   - Verify registry credentials
   - Check image name and tag
   - Ensure network connectivity

2. **Database Connection Issues**
   - Verify connection strings
   - Check firewall rules
   - Validate credentials

3. **Terraform State Conflicts**
   - Use remote state with locking
   - Coordinate team deployments
   - Use workspaces

4. **Kubernetes Pod Crashes**
   - Check pod logs: `kubectl logs <pod-name>`
   - Verify resource limits
   - Check health probe configurations

---

## Next Steps

1. Choose your deployment path based on requirements
2. Review the specific documentation for your chosen method
3. Set up prerequisites
4. Follow the deployment guide
5. Configure monitoring and alerting
6. Document your deployment specifics

---

## Support and Resources

- **Documentation**: See individual README files in each directory
- **Issues**: [GitHub Issues](https://github.com/MicrosoftLearning/eShopOnWeb/issues)
- **Kubernetes Docs**: https://kubernetes.io/docs/
- **Terraform Docs**: https://www.terraform.io/docs
- **Azure Docs**: https://docs.microsoft.com/azure/

---

## Contributing

To add new deployment options:
1. Create a new directory under `/deploy/`
2. Include comprehensive README.md
3. Provide example configurations
4. Update this guide
5. Submit a pull request
