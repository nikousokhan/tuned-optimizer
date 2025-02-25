#!/bin/bash
# Tuned Optimizer for SysAdmins & DevOps
# Author: Nikousokhan

set -e

# Function to check if tuned is installed
check_tuned() {
    if ! command -v tuned-adm &> /dev/null; then
        echo "Tuned is not installed. Installing now..."
        if [ -f /etc/redhat-release ]; then
            sudo dnf install -y tuned
        elif [ -f /etc/debian_version ]; then
            sudo apt install -y tuned
        else
            echo "Unsupported OS. Please install Tuned manually."
            exit 1
        fi
    fi
    echo "Tuned is installed."
}

# Function to check active Tuned profile and applied sysctl settings
check_tuned_settings() {
    echo "Checking Tuned active profile and applied sysctl settings..."
    tuned-adm active | tee /tmp/tuned_current_settings.txt
    sysctl -a | tee /tmp/sysctl_current_settings.txt
}

# Function to detect important services
check_services() {
    SERVICES=("redis" "kafka" "rabbitmq" "mariadb" "mongod" "postgresql" "nginx" "haproxy" "docker" "kubelet" "openshift" "libvirtd" "openstack-nova-compute" "opennebula")
    ACTIVE_SERVICES=()
    
    for SERVICE in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$SERVICE" || pgrep -x "$SERVICE" > /dev/null; then
            ACTIVE_SERVICES+=("$SERVICE")
        fi
    done
    
    echo "Active services: ${ACTIVE_SERVICES[*]}"
    if [ ${#ACTIVE_SERVICES[@]} -eq 0 ]; then
        echo "No critical services detected. Applying standard tuning..."
        apply_standard_tuning
    else
        apply_service_specific_tuning "${ACTIVE_SERVICES[@]}"
    fi
}

# Function to apply standard tuning for general servers
apply_standard_tuning() {
    echo "Applying standard OS tuning..."
    sudo tee /etc/sysctl.d/99-tuned-optimizer.conf > /dev/null <<EOL
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
fs.file-max = 2097152
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 5000
EOL
    sudo sysctl --system
    echo "Standard OS tuning applied."
}

# Function to apply service-specific tuning
apply_service_specific_tuning() {
    echo "Applying service-specific tuning..."
    sudo tee /etc/sysctl.d/99-tuned-optimizer.conf > /dev/null <<EOL
$(generate_sysctl_config "$@")
EOL
    sudo sysctl --system
    echo "Service-specific tuning applied."
}

# Function to generate sysctl configuration dynamically
generate_sysctl_config() {
    CONFIG=""
    for SERVICE in "$@"; do
        case "$SERVICE" in
            "redis"|"kafka"|"rabbitmq")
                CONFIG+="
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_tw_reuse = 1
"
                ;;
            "mariadb"|"mongod"|"postgresql")
                CONFIG+="
vm.swappiness = 1
vm.dirty_ratio = 20
vm.dirty_background_ratio = 10
vm.transparent_hugepage.enabled = never
vm.transparent_hugepage.defrag = never
"
                ;;
            "nginx"|"haproxy")
                CONFIG+="
net.core.netdev_max_backlog = 10000
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_max_syn_backlog = 8192
"
                ;;
            "docker"|"kubelet"|"openshift")
                CONFIG+="
fs.file-max = 4194304
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 5
"
                ;;
            "libvirtd"|"openstack-nova-compute"|"opennebula")
                CONFIG+="
vm.dirty_expire_centisecs = 500
vm.dirty_ratio = 20
fs.file-max = 2097152
"
                ;;
        esac
    done
    echo "$CONFIG"
}

# Function to validate sysctl changes
validate_sysctl_changes() {
    echo "Validating sysctl changes..."
    diff /tmp/sysctl_current_settings.txt <(sysctl -a) || echo "⚠️ Some sysctl settings may have changed unexpectedly!"
}

# Main execution
check_tuned
check_tuned_settings
check_services
validate_sysctl_changes

echo "System optimized dynamically based on active services!"
