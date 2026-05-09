#!/bin/bash

set -euo pipefail

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

PUBLIC_IP=$(curl -s ifconfig.me)

CLUSTER_NAME="retail"

KIND_CONFIG="./kind-cluster/kind-config.yml"

ARGO_NAMESPACE="argocd"

ARGO_RELEASE_NAME="argocd"

ARGO_HELM_REPO="https://argoproj.github.io/argo-helm"

ARGO_VALUES_FILE="./kind-cluster/argocd-install-values.yaml"

PROJECT_FILE="argocd-project.yaml"

ROOT_APP_FILE="root-app.yaml"

ARGOCD_LOCAL_PORT="8080"

APP_NAMESPACE="dev"

APP_SERVICE="ui-dev-service"

APP_LOCAL_PORT="8888"

APP_TARGET_PORT="8080"

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

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =========================================================
# CHECK DEPENDENCIES
# =========================================================

check_dependencies() {

    log_info "Checking required tools..."

    tools=("docker" "kubectl" "helm" "kind")

    for tool in "${tools[@]}"
    do
        if ! command -v $tool &> /dev/null
        then
            log_error "$tool is not installed."
            exit 1
        fi
    done

    log_info "All dependencies found."
}

# =========================================================
# CHECK DOCKER
# =========================================================

check_docker() {

    log_info "Checking Docker daemon..."

    if ! docker log_info > /dev/null 2>&1
    then
        log_error "Docker is not running."
        exit 1
    fi

    log_info "Docker is running."
}

# =========================================================
# MOUNT EBS
# =========================================================

mount_ebs() {

    log_info "Checking EBS mount..."

    if mountpoint -q "$EBS_MOUNT_PATH"
    then
        log_warn "EBS already mounted at $EBS_MOUNT_PATH"
    else

        sudo mkdir -p "$EBS_MOUNT_PATH"

        sudo mount "$EBS_DEVICE" "$EBS_MOUNT_PATH"

        log_info "EBS mounted successfully."
    fi
}

# =========================================================
# CREATE KIND CLUSTER
# =========================================================

create_kind_cluster() {

    log_info "Checking if kind cluster exists..."

    if kind get clusters | grep -q "$CLUSTER_NAME"
    then
        log_warn "Kind cluster already exists."
    else

        log_info "Creating kind cluster..."

        kind create cluster \
            --name "$CLUSTER_NAME" \
            --config "$KIND_CONFIG"

        log_info "Kind cluster created."
        
        # no need to set context for kubectl
    fi
}

# =========================================================
# INSTALL ARGOCD
# =========================================================

install_argocd() {

#    log_info "Checking ArgoCD namespace..."
#
#    kubectl create namespace "$ARGO_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
#
#    log_info "Adding ArgoCD Helm repo..."
#
#    helm repo add argo "$ARGO_HELM_REPO" || true
#
#    helm repo update

    log_info "Installing ArgoCD..."

    helm install "$ARGO_RELEASE_NAME" argo/argo-cd \
        -n "$ARGO_NAMESPACE" \
        -f "$ARGO_VALUES_FILE" \
        --create-namespace

    log_info "ArgoCD installation completed."
}

# =========================================================
# WAIT FOR ARGOCD
# =========================================================

wait_for_argocd() {

    log_info "Waiting for ArgoCD server..."

    kubectl wait \
        --for=condition=available \
        deployment/argocd-server \
        -n "$ARGO_NAMESPACE" \
        --timeout=300s

    log_info "ArgoCD is ready."
}

# =========================================================
# PORT FORWARD ARGOCD
# =========================================================

port_forward_argocd() {

    log_info "Starting ArgoCD port-forward..."

    kubectl port-forward svc/argocd-server \
      -n "$ARGO_NAMESPACE" \
      ${ARGOCD_LOCAL_PORT}:80 \
      --address=0.0.0.0 \
      > /dev/null 2>&1 &

    sleep 3
    
}

# =========================================================
# FETCH ARGOCD PASSWORD
# =========================================================

fetch_argocd_password() {

    log_info "Fetching ArgoCD admin password..."

    ARGO_PASSWORD=$(kubectl -n "$ARGO_NAMESPACE" get secret argocd-initial-admin-secret \
      -o jsonpath="{.data.password}" | base64 -d)

    echo ""
    echo "========================================="
    echo " ArgoCD Login"
    echo "-----------------------------------------"
    echo " URL:      http://${PUBLIC_IP}:$ARGOCD_LOCAL_PORT"
    echo " Username: admin"
    echo " Password: $ARGO_PASSWORD"
    echo "========================================="
    echo ""
}


# =========================================================
# APPLY PROJECT
# =========================================================

apply_project() {

    log_info "Applying project to ArgoCD..."

    kubectl apply -f "$PROJECT_FILE" -n "$ARGO_NAMESPACE"
    
    echo ""
}

# =========================================================
# APPLY ROOT APP
# =========================================================

apply_root_app() {

    log_info "Applying root ArgoCD application..."

    kubectl apply -f "$ROOT_APP_FILE" -n "$ARGO_NAMESPACE"

    echo ""
}

# =========================================================
# WAIT FOR APP
# =========================================================

wait_for_app() {

  log_info "Waiting for Application..."
  
  sleep 30
  
  kubectl wait \
    --for=condition=Available \
    deployment/orders-dev-dep \
    -n dev \
    --timeout=300s
    
  echo ""
}

# wait_for_app() {

#     log_info "Waiting for application to become ready..."

#     SERVICE_NAME="orders-dev-service"
#     NAMESPACE="dev"

#     TIMEOUT=300
#     INTERVAL=10
#     ELAPSED=0

#     while true
#     do

#         ENDPOINTS=$(kubectl get endpointslice \
#             -n "$NAMESPACE" \
#             -l kubernetes.io/service-name="$SERVICE_NAME" \
#             -o jsonpath='{.items[*].endpoints[*].addresses[*]}' \
#             2>/dev/null)

#         if [ ! -z "$ENDPOINTS" ]
#         then
#             log_info "Application is ready."
#             break
#         fi

#         if [ "$ELAPSED" -ge "$TIMEOUT" ]
#         then
#             log_error "Timed out waiting for application readiness."
#             exit 1
#         fi

#         echo "Waiting... (${ELAPSED}s/${TIMEOUT}s)"

#         sleep "$INTERVAL"

#         ELAPSED=$((ELAPSED + INTERVAL))

#     done
# }

# =========================================================
# PORT FORWARD APPLICATION
# =========================================================

port_forward_app() {

    log_info "Starting application port-forward..."

    kubectl port-forward svc/${APP_SERVICE} \
      -n "$APP_NAMESPACE" \
      ${APP_LOCAL_PORT}:${APP_TARGET_PORT} \
      --address=0.0.0.0 \
      > /dev/null 2>&1 &

    sleep 3

    log_info "Application available at http://${PUBLIC_IP}:$APP_LOCAL_PORT"
    echo ""
}

# =========================================================
# SHOW STATUS
# =========================================================

show_status() {

    log_info "Cluster status:"

    kubectl get nodes

    echo ""

    log_info "ArgoCD pods:"

    kubectl get pods -n "$ARGO_NAMESPACE"

    echo ""

    log_info "Applications:"

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
    
    port_forward_argocd
    
    fetch_argocd_password
    
#    apply_project

#    apply_root_app
    
#    wait_for_app

#    port_forward_app

    # show_status

    log_info "Bootstrap completed successfully 🚀"
    echo ""
}

main

echo "Running monitoring setup..."
echo ""

bash ../../prom-grafana/monitoring.sh