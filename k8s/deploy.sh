#!/bin/bash

# eShopOnWeb Kubernetes Deployment Script
# This script helps deploy the eShopOnWeb application to Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="eshoponweb"
REGISTRY=""
TAG="latest"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists kubectl; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! command_exists docker; then
        print_error "docker is not installed or not in PATH"
        exit 1
    fi
    
    # Check if kubectl can connect to cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    print_status "Prerequisites check passed!"
}

# Function to build Docker images
build_images() {
    print_status "Building Docker images..."
    
    cd "$(dirname "$0")/.."
    
    # Build Web image
    print_status "Building Web application image..."
    docker build -t eshopwebmvc:${TAG} -f src/Web/Dockerfile .
    
    # Build PublicApi image
    print_status "Building PublicApi image..."
    docker build -t eshoppublicapi:${TAG} -f src/PublicApi/Dockerfile .
    
    # Tag images for registry if specified
    if [ -n "$REGISTRY" ]; then
        print_status "Tagging images for registry: $REGISTRY"
        docker tag eshopwebmvc:${TAG} ${REGISTRY}/eshopwebmvc:${TAG}
        docker tag eshoppublicapi:${TAG} ${REGISTRY}/eshoppublicapi:${TAG}
    fi
    
    print_status "Docker images built successfully!"
}

# Function to push images to registry
push_images() {
    if [ -n "$REGISTRY" ]; then
        print_status "Pushing images to registry: $REGISTRY"
        docker push ${REGISTRY}/eshopwebmvc:${TAG}
        docker push ${REGISTRY}/eshoppublicapi:${TAG}
        print_status "Images pushed successfully!"
    else
        print_warning "No registry specified, skipping image push"
    fi
}

# Function to update image names in deployment files
update_deployment_images() {
    if [ -n "$REGISTRY" ]; then
        print_status "Updating deployment files with registry images..."
        
        # Update web deployment
        sed -i.bak "s|image: eshopwebmvc:latest|image: ${REGISTRY}/eshopwebmvc:${TAG}|g" k8s/web-deployment.yaml
        
        # Update publicapi deployment
        sed -i.bak "s|image: eshoppublicapi:latest|image: ${REGISTRY}/eshoppublicapi:${TAG}|g" k8s/publicapi-deployment.yaml
        
        print_status "Deployment files updated!"
    fi
}

# Function to restore deployment files
restore_deployment_files() {
    if [ -f "k8s/web-deployment.yaml.bak" ]; then
        mv k8s/web-deployment.yaml.bak k8s/web-deployment.yaml
    fi
    if [ -f "k8s/publicapi-deployment.yaml.bak" ]; then
        mv k8s/publicapi-deployment.yaml.bak k8s/publicapi-deployment.yaml
    fi
}

# Function to deploy to Kubernetes
deploy_k8s() {
    print_status "Deploying to Kubernetes..."
    
    cd "$(dirname "$0")"
    
    # Apply manifests in order
    kubectl apply -f namespace.yaml
    kubectl apply -f configmap.yaml
    kubectl apply -f secrets.yaml
    kubectl apply -f sqlserver.yaml
    
    # Wait for SQL Server to be ready
    print_status "Waiting for SQL Server to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/sqlserver-deployment -n ${NAMESPACE}
    
    # Deploy applications
    kubectl apply -f web-deployment.yaml
    kubectl apply -f publicapi-deployment.yaml
    kubectl apply -f ingress.yaml
    
    print_status "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/web-deployment -n ${NAMESPACE}
    kubectl wait --for=condition=available --timeout=300s deployment/publicapi-deployment -n ${NAMESPACE}
    
    print_status "Deployment completed successfully!"
}

# Function to show deployment status
show_status() {
    print_status "Deployment Status:"
    echo
    kubectl get all -n ${NAMESPACE}
    echo
    
    # Get ingress info
    if kubectl get ingress eshoponweb-ingress -n ${NAMESPACE} &> /dev/null; then
        print_status "Ingress Configuration:"
        kubectl get ingress eshoponweb-ingress -n ${NAMESPACE}
        echo
        print_status "To access the application:"
        print_status "1. Add '127.0.0.1 eshoponweb.local' to your /etc/hosts file"
        print_status "2. Configure your ingress controller to route to eshoponweb.local"
        print_status "3. Access the application at: http://eshoponweb.local"
    fi
    
    print_status "Alternatively, use port forwarding:"
    print_status "kubectl port-forward -n ${NAMESPACE} service/web-service 8080:80"
    print_status "Then access: http://localhost:8080"
}

# Function to cleanup deployment
cleanup() {
    print_status "Cleaning up deployment..."
    kubectl delete namespace ${NAMESPACE} --ignore-not-found=true
    restore_deployment_files
    print_status "Cleanup completed!"
}

# Function to show help
show_help() {
    echo "eShopOnWeb Kubernetes Deployment Script"
    echo
    echo "Usage: $0 [OPTIONS] COMMAND"
    echo
    echo "Commands:"
    echo "  deploy     - Build images and deploy to Kubernetes"
    echo "  build      - Build Docker images only"
    echo "  push       - Push images to registry"
    echo "  status     - Show deployment status"
    echo "  cleanup    - Remove deployment from Kubernetes"
    echo "  help       - Show this help message"
    echo
    echo "Options:"
    echo "  -r, --registry REGISTRY  - Docker registry for images (e.g., myregistry.azurecr.io)"
    echo "  -t, --tag TAG           - Image tag (default: latest)"
    echo "  -n, --namespace NAME    - Kubernetes namespace (default: eshoponweb)"
    echo
    echo "Examples:"
    echo "  $0 deploy                                    # Deploy with local images"
    echo "  $0 -r myregistry.azurecr.io deploy          # Deploy with registry images"
    echo "  $0 -r myregistry.azurecr.io -t v1.0 deploy  # Deploy with specific tag"
    echo "  $0 cleanup                                   # Remove deployment"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        deploy|build|push|status|cleanup|help)
            COMMAND="$1"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Execute command
case "$COMMAND" in
    deploy)
        check_prerequisites
        build_images
        push_images
        update_deployment_images
        deploy_k8s
        restore_deployment_files
        show_status
        ;;
    build)
        check_prerequisites
        build_images
        ;;
    push)
        push_images
        ;;
    status)
        show_status
        ;;
    cleanup)
        cleanup
        ;;
    help|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac