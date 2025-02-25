#!/bin/bash
# Tuned Optimizer for High Load Systems - DevOps & SysAdmins
# Author: Nikousokhan

set -e  

command -v systemd-detect-virt >/dev/null 2>&1 || { echo "systemd-detect-virt not found!"; exit 1; }
command -v tuned-adm >/dev/null 2>&1 || { echo "tuned-adm not found!"; exit 1; }
command -v sysctl >/dev/null 2>&1 || { echo "sysctl not found!"; exit 1; }

is_virtual_machine() {
    if systemd-detect-virt -q; then
        echo "Virtual Machine detected. Skipping hardware-specific tuning."
        return 0
    else
        echo "Bare-metal detected. Applying hardware optimizations."
        return 1
    fi
}

apply_baremetal_tuning() {
    echo "Applying Bare-Metal specific optimizations..."

    for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance | sudo tee "$CPU" > /dev/null
    done
    echo "CPU governor set to 'performance'."

    for DEVICE in $(ls /sys/block/ | grep -E 'sd|nvme'); do
        if [[ "$DEVICE" == nvme* ]]; then
            echo "none" | sudo tee /sys/block/"$DEVICE"/queue/scheduler > /dev/null
            echo "I/O scheduler for $DEVICE set to 'none'."
        else
            echo "mq-deadline" | sudo tee /sys/block/"$DEVICE"/queue/scheduler > /dev/null
            echo "I/O scheduler for $DEVICE set to 'mq-deadline'."
        fi
    done
}

check_tuned_settings() {
    echo "Checking Tuned active profile and applied sysctl settings..."
    tuned-adm active | tee /tmp/tuned_current_settings.txt
    sysctl -a | tee /tmp/sysctl_current_settings.txt
}

detect_system_type() {
    if systemd-detect-virt -q; then
        echo "Virtual Machine detected. Setting base profile to 'virtual-guest'."
        BASE_PROFILE="virtual-guest"
    else
        echo "Bare-Metal detected. Setting base profile to 'throughput-performance'."
        BASE_PROFILE="throughput-performance"
    fi
}

check_services() {
    SERVICES=("redis" "kafka" "rabbitmq" "mariadb" "mongod" "postgresql" "nginx" "haproxy" "docker" "kubelet" "openshift" "libvirtd" "openstack-nova-compute" "opennebula")
    ACTIVE_SERVICES=()

    for SERVICE in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$SERVICE" || pgrep -x "$SERVICE" > /dev/null; then
            echo -e "\n Service detected: $SERVICE"
            ACTIVE_SERVICES+=("$SERVICE")
        fi
    done
}

setup_custom_profile() {
    echo -e  "\n Generating custom Tuned profile..."
    CUSTOM_PROFILE_DIR="/etc/tuned/custom-profile"
    CUSTOM_PROFILE_CONF="$CUSTOM_PROFILE_DIR/tuned.conf"

    sudo mkdir -p "$CUSTOM_PROFILE_DIR"

    cat <<EOF | sudo tee "$CUSTOM_PROFILE_CONF" > /dev/null
[main]
summary=Custom Tuned Profile for Active Services
include=$BASE_PROFILE

[sysctl]
fs.file-max=4194304
fs.nr_open=2097152
fs.aio-max-nr=1048576
vm.swappiness=10
vm.dirty_ratio=30
vm.dirty_background_ratio=5
kernel.sched_migration_cost_ns=5000000
kernel.sched_latency_ns=10000000
kernel.sched_min_granularity_ns=2000000
kernel.sched_wakeup_granularity_ns=3000000
kernel.pid_max=4194304
kernel.threads-max=2097152
net.core.somaxconn=65535
net.core.netdev_max_backlog=500000
net.core.optmem_max=524287
net.core.rmem_max=268435456
net.core.wmem_max=268435456
net.ipv4.tcp_max_syn_backlog=65535
net.ipv4.tcp_rmem=4096 87380 268435456
net.ipv4.tcp_wmem=4096 65536 268435456
net.ipv4.tcp_mem=33554432 134217728 268435456
net.ipv4.tcp_keepalive_time=600
net.ipv4.tcp_keepalive_intvl=60
net.ipv4.tcp_keepalive_probes=5
net.ipv4.tcp_timestamps=0
net.ipv4.tcp_sack=0
net.ipv4.ip_local_port_range=10000 65000
vm.dirty_expire_centisecs=500
kernel.sched_autogroup_enabled=0
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_tw_reuse=1
net.netfilter.nf_conntrack_max=1048576
EOF

    for SERVICE in "${ACTIVE_SERVICES[@]}"; do
        case "$SERVICE" in
            "postgresql"|"mariadb"|"mongod")
                cat <<EOF | sudo tee -a "$CUSTOM_PROFILE_CONF" > /dev/null
($SERVICE)
net.core.netdev_max_backlog=300000
net.core.rmem_default=134217728
net.core.wmem_default=134217728
vm.dirty_background_ratio=60
vm.dirty_ratio=60
EOF
                ;;
            "nginx"|"haproxy")
                cat <<EOF | sudo tee -a "$CUSTOM_PROFILE_CONF" > /dev/null
($SERVICE)
net.ipv4.tcp_synack_retries=2
net.ipv4.tcp_syn_retries=3
EOF
                ;;
            "redis"|"kafka"|"rabbitmq")
                cat <<EOF | sudo tee -a "$CUSTOM_PROFILE_CONF" > /dev/null
($SERVICE)
vm.nr_hugepages=1024
vm.overcommit_memory=1
EOF
                ;;
            "libvirtd"|"openstack-nova-compute"|"opennebula")
                cat <<EOF | sudo tee -a "$CUSTOM_PROFILE_CONF" > /dev/null
 ($SERVICE)
vm.swappiness=5
vm.nr_hugepages=2048
EOF
                ;;
        esac
    done

    echo -e "\n Custom Tuned profile created successfully."
}

apply_tuned_profile() {
    echo -e " \n Applying Tuned profile: custom-profile"
    if tuned-adm profile custom-profile; then
        echo -e "\n Tuned profile applied successfully."
    else
        echo "Failed to apply Tuned profile! Restarting tuned service..."
        sudo systemctl restart tuned
        sleep 2
        tuned-adm profile custom-profile
    fi
}

validate_sysctl_changes() {
    echo -e "\n Validating sysctl changes..."
    sysctl -a | grep -E "fs.file-max|net.core.somaxconn|net.ipv4.tcp_keepalive_time|net.ipv4.tcp_max_syn_backlog"
}

detect_system_type
check_services
setup_custom_profile
apply_tuned_profile
validate_sysctl_changes

echo -e "\n System optimization complete!"
