#!/bin/bash

set -e

# =========================================================
# 🚀 Kubernetes GitOps Bootstrap Script
# =========================================================
# Purpose:
# Recreate complete local platform automatically:
#
# - Mount EBS
# - Create kind cluster
# - Install ArgoCD
# - Bootstrap GitOps root app
#
# =========================================================

# -----------------------------
# CONFIG
# -----------------------------

CLUSTER_NAME="retail"

KIND_CONFIG="./kind-cluster/kind-config.yml"

ARGO_NAMESPACE="argocd"

ARGO_RELEASE_NAME="argocd"

ARGO_HELM_REPO="https://argoproj.github.io/argo-helm"

ARGO_VALUES_FILE="./kind-cluster/argocd-install-values.yaml"

PROJECT_FILE="argocd-project.yaml"

ROOT_APP_FILE="root-app.yaml"

MONITORING_NAMESPACE="monitoring"

EBS_DEVICE="/dev/xvdf"

EBS_MOUNT_PATH="/mnt/postgre-data"

# -----------------------------
# COLORS
# -----------------------------

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# -----------------------------
# LOGGING HELPERS
# -----------------------------

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =========================================================
# CHECK DEPENDENCIES
# =========================================================

check_dependencies() {

    info "Checking required tools..."

    tools=("docker" "kubectl" "helm" "kind")

    for tool in "${tools[@]}"
    do
        if ! command -v $tool &> /dev/null
        then
            error "$tool is not installed."
            exit 1
        fi
    done

    info "All dependencies found."
}

# =========================================================
# CHECK DOCKER
# =========================================================

check_docker() {

    info "Checking Docker daemon..."

    if ! docker info > /dev/null 2>&1
    then
        error "Docker is not running."
        exit 1
    fi

    info "Docker is running."
}

# =========================================================
# MOUNT EBS
# =========================================================

mount_ebs() {

    info "Checking EBS mount..."

    if mountpoint -q "$EBS_MOUNT_PATH"
    then
        warn "EBS already mounted at $EBS_MOUNT_PATH"
    else

        sudo mkdir -p "$EBS_MOUNT_PATH"

        sudo mount "$EBS_DEVICE" "$EBS_MOUNT_PATH"

        info "EBS mounted successfully."
    fi
}

# =========================================================
# CREATE KIND CLUSTER
# =========================================================

create_kind_cluster() {

    info "Checking if kind cluster exists..."

    if kind get clusters | grep -q "$CLUSTER_NAME"
    then
        warn "Kind cluster already exists."
    else

        info "Creating kind cluster..."

        kind create cluster \
            --name "$CLUSTER_NAME" \
            --config "$KIND_CONFIG"

        info "Kind cluster created."
        
        # no need to set context for kubectl
    fi
}

# =========================================================
# INSTALL ARGOCD
# =========================================================

install_argocd() {

#    info "Checking ArgoCD namespace..."
#
#    kubectl create namespace "$ARGO_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
#
#    info "Adding ArgoCD Helm repo..."
#
#    helm repo add argo "$ARGO_HELM_REPO" || true
#
#    helm repo update

    info "Installing ArgoCD..."

    helm install "$ARGO_RELEASE_NAME" argo/argo-cd \
        -n "$ARGO_NAMESPACE" \
        -f "$ARGO_VALUES_FILE" \
        --create-namespace

    info "ArgoCD installation completed."
}

# =========================================================
# WAIT FOR ARGOCD
# =========================================================

wait_for_argocd() {

    info "Waiting for ArgoCD server..."

    kubectl wait \
        --for=condition=available \
        deployment/argocd-server \
        -n "$ARGO_NAMESPACE" \
        --timeout=300s

    info "ArgoCD is ready."
}

# =========================================================
# APPLY PROJECT
# =========================================================

apply_project() {

    info "Applying project to ArgoCD..."

    kubectl apply -f "$PROJECT_FILE" -n "$ARGO_NAMESPACE"

    info "Project applied."
}

# =========================================================
# APPLY ROOT APP
# =========================================================

apply_root_app() {

    info "Applying root ArgoCD application..."

    kubectl apply -f "$ROOT_APP_FILE" -n "$ARGO_NAMESPACE"

    info "Root application applied."
}

# =========================================================
# SHOW STATUS
# =========================================================

show_status() {

    info "Cluster status:"

    kubectl get nodes

    echo ""

    info "ArgoCD pods:"

    kubectl get pods -n "$ARGO_NAMESPACE"

    echo ""

    info "Applications:"

    kubectl get applications -n "$ARGO_NAMESPACE" || true
}

# =========================================================
# MAIN
# =========================================================

main() {

    # check_dependencies

    # check_docker

    # mount_ebs

    create_kind_cluster

    install_argocd

    wait_for_argocd
    
    apply_project

    apply_root_app

    # show_status

    info "Bootstrap completed successfully 🚀"
}

main