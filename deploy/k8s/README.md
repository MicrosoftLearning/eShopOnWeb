# Kubernetes Deployment Guide

This directory contains Kubernetes manifests for deploying the eShopOnWeb application to a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster (AKS, EKS, GKE, or local cluster like minikube/kind)
- `kubectl` CLI installed and configured
- Container images built and pushed to a container registry (ACR, Docker Hub, etc.)
- (Optional) `kustomize` CLI for environment-specific deployments

## Architecture

The deployment includes:
- **Web Application** (eshop-web): Frontend MVC application
- **Public API** (eshop-publicapi): Backend REST API
- **ConfigMap**: Application configuration
- **Secret**: Sensitive configuration data
- **Services**: ClusterIP for API, LoadBalancer for Web
- **Ingress**: Optional ingress for external access

## Quick Start

### 1. Build and Push Container Images

First, build the container images and push them to your registry:

```bash
# From the repository root
docker-compose build

# Tag and push to your registry (e.g., Azure Container Registry)
docker tag eshopwebmvc:latest <your-registry>.azurecr.io/eshopwebmvc:latest
docker tag eshoppublicapi:latest <your-registry>.azurecr.io/eshoppublicapi:latest

docker push <your-registry>.azurecr.io/eshopwebmvc:latest
docker push <your-registry>.azurecr.io/eshoppublicapi:latest
```

### 2. Update Kustomization

Edit `kustomization.yaml` to point to your container registry:

```yaml
images:
  - name: eshopwebmvc
    newName: <your-registry>.azurecr.io/eshopwebmvc
    newTag: latest
  - name: eshoppublicapi
    newName: <your-registry>.azurecr.io/eshoppublicapi
    newTag: latest
```

### 3. Deploy Using kubectl

```bash
# Deploy all resources
kubectl apply -k .

# Or deploy individual manifests
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f web-deployment.yaml
kubectl apply -f web-service.yaml
kubectl apply -f publicapi-deployment.yaml
kubectl apply -f publicapi-service.yaml
kubectl apply -f ingress.yaml
```

### 4. Verify Deployment

```bash
# Check namespace
kubectl get namespaces | grep eshoponweb

# Check pods
kubectl get pods -n eshoponweb

# Check services
kubectl get services -n eshoponweb

# Get Web service external IP (if LoadBalancer)
kubectl get service eshop-web-service -n eshoponweb
```

## Environment-Specific Deployments

Use Kustomize overlays for different environments:

### Development
```bash
kubectl apply -k overlays/dev/
```

### Staging
```bash
kubectl apply -k overlays/staging/
```

### Production
```bash
kubectl apply -k overlays/production/
```

## Configuration

### ConfigMap
Edit `configmap.yaml` to change application settings:
- `ASPNETCORE_ENVIRONMENT`: Development, Staging, Production
- `UseOnlyInMemoryDatabase`: true/false
- `ASPNETCORE_HTTP_PORTS`: HTTP port

### Secrets
Update `secret.yaml` with your database credentials:
- `CATALOG_DB_CONNECTION`: Catalog database connection string
- `IDENTITY_DB_CONNECTION`: Identity database connection string

⚠️ **Important**: In production, use proper secret management (Azure Key Vault, Kubernetes Secrets, Sealed Secrets, etc.)

## Private Container Registry

If using a private container registry, create a registry secret:

```bash
kubectl create secret docker-registry registry-credentials \
  --docker-server=<your-registry>.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email> \
  -n eshoponweb
```

Then uncomment the `imagePullSecrets` section in deployment files.

## Ingress Configuration

The included `ingress.yaml` uses NGINX Ingress Controller. Update annotations for your ingress controller:

### For Azure Application Gateway Ingress Controller:
```yaml
annotations:
  kubernetes.io/ingress.class: azure/application-gateway
  appgw.ingress.kubernetes.io/ssl-redirect: "true"
```

### Update the host:
```yaml
spec:
  rules:
  - host: your-domain.com
```

## Monitoring and Scaling

### View logs
```bash
kubectl logs -f deployment/eshop-web -n eshoponweb
kubectl logs -f deployment/eshop-publicapi -n eshoponweb
```

### Scale deployments
```bash
kubectl scale deployment eshop-web --replicas=3 -n eshoponweb
kubectl scale deployment eshop-publicapi --replicas=3 -n eshoponweb
```

### Horizontal Pod Autoscaling
```bash
kubectl autoscale deployment eshop-web --cpu-percent=70 --min=2 --max=10 -n eshoponweb
```

## Validation

Validate manifests before applying:

```bash
# Run the validation script (checks YAML syntax and kubectl dry-run if available)
./validate.sh

# Or manually validate with kubectl
kubectl apply -k . --dry-run=client

# Server-side dry-run
kubectl apply -k . --dry-run=server

# Validate individual files
kubectl apply -f web-deployment.yaml --dry-run=client
```

## Cleanup

To remove all resources:

```bash
# Using kustomize
kubectl delete -k .

# Or delete namespace (removes all resources)
kubectl delete namespace eshoponweb
```

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n eshoponweb
kubectl logs <pod-name> -n eshoponweb
```

### Service not accessible
```bash
kubectl get endpoints -n eshoponweb
kubectl describe service eshop-web-service -n eshoponweb
```

### Image pull errors
- Verify registry credentials
- Check image name and tag
- Ensure imagePullSecrets is configured

## Compatibility

These manifests are compatible with:
- Azure Kubernetes Service (AKS)
- Amazon Elastic Kubernetes Service (EKS)
- Google Kubernetes Engine (GKE)
- On-premises Kubernetes clusters
- Local development clusters (minikube, kind, k3s)

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kustomize Documentation](https://kustomize.io/)
- [Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
