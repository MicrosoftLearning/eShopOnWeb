# eShopOnWeb Kubernetes Deployment

This directory contains Kubernetes manifests for deploying the eShopOnWeb application to a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster (v1.20+)
- kubectl configured to connect to your cluster
- NGINX Ingress Controller (for external access)
- Docker images built for the application

## Build Docker Images

Before deploying, build the required Docker images:

```bash
# From the repository root
docker build -t eshopwebmvc:latest -f src/Web/Dockerfile .
docker build -t eshoppublicapi:latest -f src/PublicApi/Dockerfile .
```

If using a container registry, tag and push the images:

```bash
# Example for Azure Container Registry
docker tag eshopwebmvc:latest your-registry.azurecr.io/eshopwebmvc:latest
docker tag eshoppublicapi:latest your-registry.azurecr.io/eshoppublicapi:latest
docker push your-registry.azurecr.io/eshopwebmvc:latest
docker push your-registry.azurecr.io/eshoppublicapi:latest
```

Then update the image names in the deployment files.

## Deployment

Deploy the application to Kubernetes:

```bash
# Apply all manifests
kubectl apply -f k8s/

# Or apply them in order:
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/sqlserver.yaml
kubectl apply -f k8s/web-deployment.yaml
kubectl apply -f k8s/publicapi-deployment.yaml
kubectl apply -f k8s/ingress.yaml
```

## Access the Application

### Using Ingress (recommended)

1. Ensure NGINX Ingress Controller is installed in your cluster
2. Add the following to your `/etc/hosts` file (or equivalent):
   ```
   <ingress-controller-ip> eshoponweb.local
   ```
3. Access the application at: http://eshoponweb.local

### Using Port Forwarding (for testing)

```bash
# Web application
kubectl port-forward -n eshoponweb service/web-service 8080:80

# Public API
kubectl port-forward -n eshoponweb service/publicapi-service 8081:80
```

Then access:
- Web: http://localhost:8080
- API: http://localhost:8081

## Configuration

### Environment Variables

The application configuration is managed through:
- `configmap.yaml`: Non-sensitive configuration
- `secrets.yaml`: Sensitive data like connection strings

### Database

The deployment includes:
- SQL Server running in a container
- Persistent storage using emptyDir (consider using PersistentVolumes for production)

For production, consider:
- Using an external managed database service
- Implementing proper backup strategies
- Using PersistentVolumes for data persistence

## Scaling

Scale the application components:

```bash
# Scale web frontend
kubectl scale deployment web-deployment -n eshoponweb --replicas=3

# Scale API
kubectl scale deployment publicapi-deployment -n eshoponweb --replicas=3
```

## Monitoring

Check deployment status:

```bash
# Check all resources
kubectl get all -n eshoponweb

# Check pod logs
kubectl logs -f deployment/web-deployment -n eshoponweb
kubectl logs -f deployment/publicapi-deployment -n eshoponweb
kubectl logs -f deployment/sqlserver-deployment -n eshoponweb
```

## Cleanup

Remove the deployment:

```bash
kubectl delete namespace eshoponweb
```

## Notes

- The current configuration uses in-cluster SQL Server with basic authentication
- For production deployments, consider:
  - Using managed database services
  - Implementing proper secrets management (e.g., Azure Key Vault, HashiCorp Vault)
  - Setting up monitoring and logging
  - Configuring resource limits and requests appropriately
  - Using init containers for database migrations
  - Implementing network policies for security