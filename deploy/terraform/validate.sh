#!/bin/bash
# Terraform configuration validation script
# This script validates Terraform configurations

set -e

echo "🔍 Validating Terraform configurations..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ALL_VALID=true

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}✗${NC} Terraform is not installed"
    echo "   Please install Terraform from https://www.terraform.io/downloads"
    exit 1
fi

echo "✓ Terraform version: $(terraform version -json | python3 -c 'import sys, json; print(json.load(sys.stdin)["terraform_version"])')"
echo ""

# Initialize Terraform (required for validation)
echo "📦 Initializing Terraform..."
if terraform init -backend=false &> /dev/null; then
    echo -e "${GREEN}✓${NC} Terraform initialized successfully"
else
    echo -e "${RED}✗${NC} Terraform initialization failed"
    ALL_VALID=false
fi

echo ""

# Validate Terraform configuration
echo "🔎 Validating Terraform configuration..."
if terraform validate; then
    echo -e "${GREEN}✓${NC} Terraform validation passed"
else
    echo -e "${RED}✗${NC} Terraform validation failed"
    ALL_VALID=false
fi

echo ""

# Format check
echo "📝 Checking Terraform formatting..."
if terraform fmt -check -recursive; then
    echo -e "${GREEN}✓${NC} All files are properly formatted"
else
    echo -e "${YELLOW}⚠${NC}  Some files need formatting (run 'terraform fmt -recursive')"
fi

echo ""

# Validate modules (already validated as part of root module)
echo "📦 Terraform modules validated as part of root configuration"

echo ""

if [ "$ALL_VALID" = true ]; then
    echo -e "${GREEN}✅ All validations passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Copy terraform.tfvars.example to terraform.tfvars"
    echo "  2. Update variables in terraform.tfvars"
    echo "  3. Run 'terraform plan' to preview changes"
    echo "  4. Run 'terraform apply' to deploy"
    exit 0
else
    echo -e "${RED}❌ Some validations failed!${NC}"
    exit 1
fi
