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

# Function to enable and start tuned service
enable_tuned() {
    sudo systemctl enable --now tuned
    echo "Tuned service enabled and started."
}

# Function to check if system is a Virtual Machine
is_virtual_machine() {
    if systemd-detect-virt | grep -qE 'kvm|vmware|hyperv|qemu|xen'; then
        return 0  # VM detected
    else
        return 1  # Bare-metal detected
    fi
}

# Function to optimize CPU governor (only for Bare-Metal)
optimize_cpu_governor() {
    if is_virtual_machine; then
        echo "Skipping CPU governor tuning (Virtual Machine detected)"
        return
    fi
    echo "Optimizing CPU governor..."
    for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance | sudo tee $CPU > /dev/null
    done
    echo "✅ CPU governor set to 'performance'"
}

# Function to optimize disk I/O scheduler (only for Bare-Metal or DB servers)
optimize_disk_io() {
    if is_virtual_machine && ! systemctl is-active --quiet mysql && ! systemctl is-active --quiet mariadb && ! systemctl is-active --quiet postgresql && ! systemctl is-active --quiet mongod; then
        echo "⚠️ Skipping Disk I/O tuning (Virtual Machine detected and no DB services running)"
        return
    fi
    echo "Optimizing Disk I/O Scheduler..."
    for DEVICE in $(ls /sys/block/ | grep -E 'sd|nvme'); do
        echo mq-deadline | sudo tee /sys/block/$DEVICE/queue/scheduler > /dev/null
    done
    echo "✅ Disk I/O Scheduler set to 'mq-deadline'"
}

# Function to apply best profile based on system type
apply_best_profile() {
    echo "Detecting best profile for your system..."
    
    if systemctl is-active --quiet docker || [ -d "/var/lib/docker" ]; then
        PROFILE="throughput-performance"
    elif systemctl is-active --quiet kubelet; then
        PROFILE="throughput-performance"
    elif systemctl is-active --quiet mysql || systemctl is-active --quiet mariadb || systemctl is-active --quiet postgresql || systemctl is-active --quiet mongod; then
        PROFILE="latency-performance"
    elif systemctl is-active --quiet libvirtd || systemctl is-active --quiet opennebula || systemctl is-active --quiet openstack-nova-compute; then
        PROFILE="virtual-guest"
    elif systemctl is-active --quiet networkd || [ -d "/etc/nginx" ] || systemctl is-active --quiet haproxy; then
        PROFILE="network-latency"
    elif systemctl is-active --quiet redis || systemctl is-active --quiet rabbitmq-server || systemctl is-active --quiet elasticsearch; then
        PROFILE="latency-performance"
    else
        PROFILE="balanced"
    fi
    
    echo "Applying profile: $PROFILE"
    sudo tuned-adm profile $PROFILE
}

# Function to display system performance overview
system_performance_overview() {
    echo "ystem Performance Overview:"
    echo "CPU Load: $(uptime)"
    echo "Memory Usage: $(free -h)"
    echo "Swap Usage: $(swapon --summary)"
    echo "Disk Usage: $(df -h /)"
}

# Function to optimize database settings
optimize_database() {
    echo "Database Performance Checks..."
    if systemctl is-active --quiet mysql || systemctl is-active --quiet mariadb; then
        echo "Optimizing MySQL/MariaDB settings..."
        sudo mysql -e "SET GLOBAL innodb_buffer_pool_size = 1024*1024*1024;"
    fi

    if systemctl is-active --quiet postgresql; then
        echo "Optimizing PostgreSQL settings..."
        sudo -u postgres psql -c "ALTER SYSTEM SET work_mem = '64MB';"
    fi

    if systemctl is-active --quiet mongod; then
        echo "Optimizing MongoDB settings..."
        sudo sed -i 's/#wiredTigerCacheSizeGB:/wiredTigerCacheSizeGB: 1/' /etc/mongod.conf
        sudo systemctl restart mongod
    fi
}

# Main execution
check_tuned
enable_tuned
list_profiles
optimize_cpu_governor
optimize_disk_io
system_performance_overview
apply_best_profile
optimize_database

echo "System optimized with Tuned!"
