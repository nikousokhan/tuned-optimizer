# Tuned Optimizer for SysAdmins & DevOps

![Tuned Optimizer](https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Tuned_Logo.svg/120px-Tuned_Logo.svg.png)

## Overview
**Tuned Optimizer** is an advanced **Linux performance tuning automation tool** designed for **SysAdmins & DevOps Engineers**. It dynamically optimizes system settings using **Tuned & sysctl**, ensuring optimal performance for various workloads, including **databases, web servers, virtualization, and containerized environments**.

This script:
- **Detects running services** (e.g., Redis, PostgreSQL, OpenStack, Kubernetes, etc.) and applies **service-specific tuning**.
- **Uses `Tuned` for dynamic optimizations** and **locks critical `sysctl` settings** to prevent unintended modifications.
- **Validates `sysctl` changes** before and after applying configurations, ensuring consistency.

---

## Key Features
 **Automatic service detection** – Applies optimizations based on running workloads.
 **Prevents conflicts between `Tuned` and `sysctl`** – Ensures stable and predictable performance.
 **Enterprise-ready performance tuning** – Supports **bare-metal, virtualized, and cloud environments**.
 **Optimized kernel settings for databases, networking, and containers**.
 **Live validation of system parameters** – Detects and alerts if `sysctl` changes unexpectedly.

---

## Installation & Usage

### **1 Clone the repository**
```bash
git clone https://github.com/your-repo/tuned-optimizer.git
cd tuned-optimizer
```

### **2 Run the script**
```bash
chmod +x auto-tune.sh
./auto-tune.sh
```

### **3 Verify applied settings**
```bash
tuned-adm active
sysctl -a | grep -E "swappiness|tcp_max_syn_backlog|netdev_max_backlog"
```

---

## How It Works
| Step | Action |
|------|--------|
| 1 | Detects active services using `systemctl` and `pgrep`. |
| 2 | If no critical services are found, applies **standard system tuning**. |
| 3 | If services are detected, applies **custom `sysctl` configurations** for each workload. |
| 4 | Checks and validates `Tuned` profiles to ensure settings match active workloads. |
| 5 | Verifies `sysctl` settings after applying changes to prevent unintended modifications. |

---

## Professional Monitoring with Netdata
**If you need real-time graphical monitoring, `Netdata` is an excellent tool that provides detailed insights into `Tuned`, CPU, RAM, disk, network usage, and kernel settings.**

### **1 Install `Netdata` on any Linux distribution:**
```bash
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

### **2 Enable and start the `Netdata` service:**
```bash
sudo systemctl enable --now netdata
```

### **3 Access the graphical dashboard via browser:**
```bash
http://<VM-IP>:19999
```
**With this tool, you can monitor `Tuned` changes and their impact on system performance in real time.**

---

## Service-Specific Optimizations
| Service Type  | Applied Optimizations |
|--------------|----------------------|
| **Databases (MySQL, PostgreSQL, MongoDB, MariaDB)** | Low swappiness, disable THP, increase dirty ratio for better caching |
| **Web Servers (NGINX, HAProxy)** | Increase backlog queue, optimize TCP buffers for high concurrency |
| **Message Brokers (Kafka, RabbitMQ, Redis)** | Increase connection limits, reduce TIME_WAIT for better performance |
| **Containers (Docker, Kubernetes, OpenShift)** | Increase file descriptor limits, optimize keepalive intervals |
| **Virtualization (KVM, OpenStack, OpenNebula)** | Increase dirty expiration, optimize memory paging |

---

## License
This project is licensed under the **MIT License**. See the `LICENSE` file for details.

---

## Contributing
We welcome contributions! Feel free to **fork the repo, submit pull requests, or open issues** for feature requests.

---

## Contact & Support
For questions and support, please open an issue on **[GitHub Issues](https://github.com/your-repo/tuned-optimizer/issues)** or reach out via **LinkedIn**.

---

**Optimize your Linux system dynamically with Tuned Optimizer!**
