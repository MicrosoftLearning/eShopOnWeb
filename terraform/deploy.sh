#!/bin/bash

# eShopOnWeb Terraform Deployment Script
# This script helps deploy the eShopOnWeb infrastructure using Terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
    
    if ! command_exists terraform; then
        print_error "Terraform is not installed or not in PATH"
        exit 1
    fi
    
    if ! command_exists az; then
        print_error "Azure CLI is not installed or not in PATH"
        exit 1
    fi
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure. Please run: az login"
        exit 1
    fi
    
    print_status "Prerequisites check passed!"
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    cd "$(dirname "$0")"
    terraform init
    print_status "Terraform initialized successfully!"
}

# Function to validate configuration
validate_config() {
    print_status "Validating Terraform configuration..."
    terraform validate
    terraform fmt -check=true
    print_status "Configuration validation passed!"
}

# Function to plan deployment
plan_deployment() {
    print_status "Creating Terraform plan..."
    
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        print_warning "Please edit terraform.tfvars with your specific values before running apply!"
        exit 1
    fi
    
    terraform plan -out=tfplan
    print_status "Plan created successfully! Review the plan above."
}

# Function to apply deployment
apply_deployment() {
    if [ ! -f "tfplan" ]; then
        print_error "No plan file found. Please run 'plan' first."
        exit 1
    fi
    
    print_status "Applying Terraform configuration..."
    terraform apply tfplan
    print_status "Infrastructure deployed successfully!"
    
    # Clean up plan file
    rm -f tfplan
}

# Function to destroy deployment
destroy_deployment() {
    print_warning "This will destroy all infrastructure resources!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        print_status "Destroying infrastructure..."
        terraform destroy -auto-approve
        print_status "Infrastructure destroyed successfully!"
    else
        print_status "Destroy cancelled."
    fi
}

# Function to show outputs
show_outputs() {
    print_status "Terraform Outputs:"
    terraform output
}

# Function to show help
show_help() {
    echo "eShopOnWeb Terraform Deployment Script"
    echo
    echo "Usage: $0 COMMAND"
    echo
    echo "Commands:"
    echo "  init       - Initialize Terraform"
    echo "  validate   - Validate Terraform configuration"
    echo "  plan       - Create deployment plan"
    echo "  apply      - Apply deployment plan"
    echo "  destroy    - Destroy infrastructure"
    echo "  output     - Show deployment outputs"
    echo "  deploy     - Run init, validate, plan, and apply in sequence"
    echo "  help       - Show this help message"
    echo
    echo "Prerequisites:"
    echo "  - Terraform installed"
    echo "  - Azure CLI installed and logged in (az login)"
    echo "  - terraform.tfvars file configured"
    echo
    echo "Example workflow:"
    echo "  $0 init       # Initialize Terraform"
    echo "  $0 plan       # Review deployment plan"
    echo "  $0 apply      # Deploy infrastructure"
    echo "  $0 output     # Show deployment outputs"
    echo
    echo "  Or use the combined command:"
    echo "  $0 deploy     # Run all steps in sequence"
}

# Parse command line arguments
COMMAND="$1"

# Execute command
case "$COMMAND" in
    init)
        check_prerequisites
        init_terraform
        ;;
    validate)
        validate_config
        ;;
    plan)
        check_prerequisites
        plan_deployment
        ;;
    apply)
        check_prerequisites
        apply_deployment
        ;;
    destroy)
        check_prerequisites
        destroy_deployment
        ;;
    output)
        show_outputs
        ;;
    deploy)
        check_prerequisites
        init_terraform
        validate_config
        plan_deployment
        
        print_status "Review the plan above. Do you want to apply these changes?"
        read -p "Continue with apply? (yes/no): " confirm
        
        if [ "$confirm" = "yes" ]; then
            apply_deployment
            show_outputs
        else
            print_status "Deployment cancelled."
            rm -f tfplan
        fi
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