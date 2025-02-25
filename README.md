# Tuned Optimizer for SysAdmins & DevOps

![Tuned Optimizer](https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Tuned_Logo.svg/120px-Tuned_Logo.svg.png)

## Overview
**Tuned Optimizer** is an advanced **Linux performance tuning automation tool** designed for **SysAdmins & DevOps Engineers**. It dynamically optimizes system settings using **Tuned & sysctl**, ensuring optimal performance for various workloads, including **databases, web servers, virtualization, and containerized environments**.

This role:
- **Detects running services** (e.g., Redis, PostgreSQL, OpenStack, Kubernetes, etc.) and applies **service-specific tuning**.
- **Differentiates between Bare-Metal and Virtual Machines**, ensuring the correct optimizations are applied.
- **For Bare-Metal systems**, applies additional low-level optimizations such as:
  - Setting **CPU governor to performance mode** for maximum performance.
  - Configuring **I/O scheduler** for better disk performance.
  - Applying **essential OS-level tunings** for stability and efficiency.
- **Uses `Tuned` for dynamic optimizations** and **locks critical `sysctl` settings** to prevent unintended modifications.
- **Validates `sysctl` changes** before and after applying configurations, ensuring consistency.
- **Runs periodically via `systemd timer` to maintain optimal performance over time.**

---

## Key Features
✅ **Automatic detection of Bare-Metal vs Virtual Machine** – Ensures correct optimizations per environment.  
✅ **Automatic service detection** – Applies optimizations based on running workloads.  
✅ **Prevents conflicts between `Tuned` and `sysctl`** – Ensures stable and predictable performance.  
✅ **Enterprise-ready performance tuning** – Supports **bare-metal, virtualized, and cloud environments**.  
✅ **Optimized kernel settings for databases, networking, and containers**.  
✅ **Bare-Metal specific tuning** – Configures **CPU governor, I/O scheduler, and critical OS-level tunings**.  
✅ **Live validation of system parameters** – Detects and alerts if `sysctl` changes unexpectedly.  
✅ **Automated execution via `systemd timer`** – Ensures periodic tuning without manual intervention.  

---

## Installation & Usage (Ansible-Based)

### **1 Clone the repository**
```bash
git clone https://github.com/your-repo/tuned-optimizer.git
cd tuned-optimizer
```

### **2 Run the Ansible Playbook**
```bash
ansible-playbook site.yml --tags all
```

🔹 **To install only `Tuned` optimizations:**  
```bash
ansible-playbook site.yml --tags tuned
```
🔹 **To install only `Netdata` monitoring:**  
```bash
ansible-playbook site.yml --tags netdata
```
🔹 **To enable periodic execution (`systemd timer`):**  
```bash
ansible-playbook site.yml --tags timer
```

---

## How It Works
| Step | Action |
|------|--------|
| 1 | Detects if the system is **Bare-Metal or Virtual Machine** and applies the appropriate optimizations. |
| 2 | If Bare-Metal, applies **CPU governor, I/O scheduler, and essential OS-level tuning**. |
| 3 | Scans for critical workloads (Databases, Web Servers, Virtualization, etc.) and applies **custom tuning**. |
| 4 | Configures and validates `Tuned` profiles to match active workloads. |
| 5 | Adjusts `sysctl` parameters dynamically and locks critical settings. |
| 6 | Enables a `systemd timer` to **automate periodic tuning** without user intervention. |

---

## Professional Monitoring with Netdata & Manual `Tuned` Monitoring

### **Netdata Dashboard (Ansible-Managed)**
**Netdata** provides real-time insights into **Tuned performance, CPU, RAM, disk, and network activity**.

**To install and configure Netdata via Ansible:**  
```bash
ansible-playbook site.yml --tags netdata
```

**To access the dashboard via browser:**  
```bash
http://<VM-IP>:19999
```

### **Manual Monitoring of `Tuned` Performance**
#### **Check Active Tuned Profile**
```bash
tuned-adm active
```
#### **View Applied Tuned Settings**
```bash
tuned-adm list
```
#### **Monitor `sysctl` Changes Made by `Tuned`**
```bash
sysctl -a | grep -E "swappiness|tcp_max_syn_backlog|netdev_max_backlog"
```
#### **Check Tuned Logs for Changes**
```bash
journalctl -u tuned --no-pager --lines 50
```
#### **Monitor System Performance with `dstat`**
```bash
dstat -tcmsdn --top-cpu --top-mem --top-io
```

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

## **Comparison: `Tuned` vs `sysctl`**
| Feature | Tuned ✅ | sysctl ✅ |
|---------|--------|---------|
| **Applies dynamic optimizations** | ✅ Yes | ❌ No |
| **Works with predefined profiles** | ✅ Yes | ❌ No |
| **Handles service-specific tuning** | ✅ Yes | ✅ Yes (manual) |
| **Can be automated with `systemd`** | ✅ Yes | ✅ Yes (but static) |
| **Detects and adapts to changing workloads** | ✅ Yes | ❌ No |
| **Direct kernel parameter adjustments** | ✅ Yes | ✅ Yes |
| **Rollback capabilities** | ✅ Yes | ❌ No |

**Conclusion:** `Tuned` provides **dynamic**, **adaptive** optimizations, while `sysctl` is **static** and best used for enforcing locked configurations.

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

🚀 **Optimize your Linux system dynamically with Tuned Optimizer!**
