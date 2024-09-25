#!/usr/bin/env bash

# # Config
export CLICOLOR=1

# # Customization variables
K3D_CLUSTER_NAME="local-example-cluster"
NS_DEV_NAME="local-devspace-example"

function usage() {
    echo -e "Usage:"
    echo -e "bash $0 build"
    echo -e "bash $0 start"
    echo -e "bash $0 stop"
    echo -e "bash $0 clean"
}

function build() {
    environment_validation
    create_k3d_cluster
    initialize_k3d_cluster
    install_k8s_service
}

function clean_up() {
    echo "Cleaning up..."
    delete_k3d_cluster
}

function initialize_k3d_cluster() {
    echo "Initializing k3d cluster"
    kubectl create ns $NS_DEV_NAME --dry-run=client -o yaml | kubectl apply -f -
}

function push_image_to_cluster() {
    k3d image import $1 -c $2 
}

function create_k3d_cluster() {
    if k3d cluster list | grep -q "$K3D_CLUSTER_NAME"; then
        echo "Local cluster $K3D_CLUSTER_NAME already exists. Skipping cluster creation."
    else
        echo "Creating local cluster $K3D_CLUSTER_NAME."
        k3d cluster create "$K3D_CLUSTER_NAME" -v /dev/mapper:/dev/mapper --port "80:80@loadbalancer" --port "443:443@loadbalancer"
        # for i in $(seq 1 3);
        #     do
        #         NODE_NAME="node-$i-$(random_string)"
        #         echo $NODE_NAME
        #         k3d node create $NODE_NAME --cluster $K3D_CLUSTER_NAME 
        #     done;
    fi
}

function random_string() {
    LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 13 | rev | cut -c 2-
}

function delete_k3d_cluster() {
    if k3d cluster list | grep -q "$K3D_CLUSTER_NAME"; then
        k3d cluster delete "$K3D_CLUSTER_NAME"
        echo "Deleted local cluster $K3D_CLUSTER_NAME"
    fi
}

function stop_k3d_cluster() {
    if k3d cluster list | grep -q "$K3D_CLUSTER_NAME"; then
        k3d cluster stop "$K3D_CLUSTER_NAME"
        echo "Stoped local cluster $K3D_CLUSTER_NAME"
    fi
}

function start_k3d_cluster() {
    if k3d cluster list | grep -q "$K3D_CLUSTER_NAME"; then
        k3d cluster start "$K3D_CLUSTER_NAME"
        echo "Started local cluster $K3D_CLUSTER_NAME"
        development_helper_text
    fi
}

function environment_validation() {
    check_tool_is_installed docker
    check_tool_is_installed k3d
    check_tool_is_installed devspace
    check_tool_is_installed kubectl
}

function check_tool_is_installed() {
    if ! command -v $1 &> /dev/null;
    then
        echo "PLease install required commands and tooling:"
        printf "$1"
        exit 1
    fi
}

function install_k8s_service() {
    echo "Installing apps in cluster..."
    cd k8s-specifications
    kubectl apply -n $NS_DEV_NAME -f . 
    cd ..
}

if ! [ $# -ge 1 ];
then
    usage
    exit 1
fi

if [ "$1" = "clean" ];
then
    clean_up
    exit 0
fi

if [ "$1" = "start" ];
then
    start_k3d_cluster
    exit 0
fi

if [ "$1" = "stop" ];
then
    stop_k3d_cluster
    exit 0
fi

if [ "$1" = "build" ];
then
    build
    exit 0
fi

usage
