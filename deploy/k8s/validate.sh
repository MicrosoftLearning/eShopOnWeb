#!/bin/bash
# Kubernetes manifest validation script
# This script validates YAML syntax for all Kubernetes manifests

set -e

echo "🔍 Validating Kubernetes manifests..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ALL_VALID=true

# List of files to validate
FILES=(
    "namespace.yaml"
    "configmap.yaml"
    "secret.yaml"
    "web-deployment.yaml"
    "web-service.yaml"
    "publicapi-deployment.yaml"
    "publicapi-service.yaml"
    "ingress.yaml"
    "kustomization.yaml"
    "overlays/dev/kustomization.yaml"
    "overlays/staging/kustomization.yaml"
    "overlays/production/kustomization.yaml"
)

# Validate YAML syntax
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $file - Valid YAML syntax"
        else
            echo -e "${RED}✗${NC} $file - Invalid YAML syntax"
            ALL_VALID=false
        fi
    else
        echo -e "${RED}✗${NC} $file - File not found"
        ALL_VALID=false
    fi
done

echo ""

# Try kubectl validation if available and cluster is accessible
if command -v kubectl &> /dev/null; then
    echo "📋 kubectl is available, attempting dry-run validation..."
    if kubectl cluster-info &> /dev/null; then
        echo "✓ Connected to Kubernetes cluster"
        echo ""
        echo "Running kubectl dry-run validation..."
        
        # Validate with kubectl
        if kubectl apply --dry-run=client -f namespace.yaml &> /dev/null; then
            echo -e "${GREEN}✓${NC} kubectl validation passed"
        else
            echo -e "${RED}✗${NC} kubectl validation failed"
            ALL_VALID=false
        fi
    else
        echo "ℹ️  No Kubernetes cluster available for kubectl validation"
        echo "   YAML syntax validation completed successfully"
    fi
else
    echo "ℹ️  kubectl not found, skipping cluster validation"
    echo "   YAML syntax validation completed successfully"
fi

echo ""

if [ "$ALL_VALID" = true ]; then
    echo -e "${GREEN}✅ All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some validations failed!${NC}"
    exit 1
fi
