# Tuned Optimizer for SysAdmins & DevOps

![Tuned Optimizer](https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Tuned_Logo.svg/120px-Tuned_Logo.svg.png)

## 🚀 Overview
**Tuned Optimizer** is an enterprise-grade performance tuning script for **Linux SysAdmins & DevOps Engineers**. It automates system performance optimization by selecting the best **Tuned profile** based on workload type while ensuring proper configuration of **CPU governor, disk I/O scheduler, and database performance tuning**. It also distinguishes between **Bare-Metal and Virtual Machines**, applying optimizations accordingly.

---

## 🎯 Features
✅ **Automatic detection of system type (Bare-Metal vs. Virtual Machine)**  
✅ **Intelligent selection of Tuned profiles based on workload**  
✅ **Optimized CPU governor settings (only for Bare-Metal servers)**  
✅ **Automatic disk I/O scheduler tuning (except for virtual machines without DB services)**  
✅ **Enhanced database performance for MySQL, PostgreSQL, and MongoDB**  
✅ **Works seamlessly on RHEL, CentOS, Fedora, Ubuntu, and Debian**  
✅ **Lightweight, no dependencies beyond Tuned & basic system utilities**  

---

## 📦 Installation
### **1️⃣ Clone the repository**
```bash
git clone https://github.com/your-repo/tuned-optimizer.git
cd tuned-optimizer
```

### **2️⃣ Run the installation script**
```bash
chmod +x install.sh
./install.sh
```

### **3️⃣ Execute the auto-tune script**
```bash
chmod +x auto-tune.sh
./auto-tune.sh
```

---

## 🔧 Usage
### **List available Tuned profiles**
```bash
tuned-adm list
```

### **Apply a specific profile manually**
```bash
sudo tuned-adm profile throughput-performance
```

### **Automatically optimize your system**
```bash
./auto-tune.sh
```

---

## 🔍 How It Works
1️⃣ **Detects if the system is running on Bare-Metal or a Virtual Machine**
- If **Bare-Metal**, applies **CPU governor** and **I/O scheduler tuning**.
- If **Virtual Machine**, skips OS-level tuning unless a database is running.

2️⃣ **Scans active workloads**
- **Database servers (MySQL, PostgreSQL, MongoDB)** → Applies `latency-performance` profile.
- **Containers (Docker, Kubernetes)** → Applies `throughput-performance` profile.
- **Virtualized Environments (OpenStack, OpenNebula, KVM)** → Applies `virtual-guest` profile.
- **Network-focused workloads (NGINX, HAProxy, Redis, RabbitMQ)** → Applies `network-latency` profile.

3️⃣ **Optimizes Database Performance** (if applicable)
- Increases `innodb_buffer_pool_size` for MySQL/MariaDB.
- Adjusts `work_mem` for PostgreSQL.
- Modifies MongoDB cache size for better efficiency.

---

## 🛠 Supported Tuned Profiles
| Profile Name               | Use Case |
|----------------------------|------------------------------------------------|
| `balanced`                 | General-purpose optimization                 |
| `throughput-performance`   | High-performance compute & containerized apps |
| `latency-performance`      | Low-latency databases & real-time apps       |
| `network-latency`         | Network-sensitive applications (NGINX, HAProxy) |
| `virtual-guest`           | Virtualized environments (KVM, OpenStack, etc.) |
| `powersave`               | Energy efficiency & low-power servers         |

---

## 📜 License
This project is licensed under the **MIT License**. See the `LICENSE` file for details.

---

## 📢 Contributing
We welcome contributions! Feel free to **fork the repo, submit pull requests, or open issues** for feature requests.

---

## 📞 Contact & Support
For questions and support, please open an issue on **[GitHub Issues](https://github.com/your-repo/tuned-optimizer/issues)** or reach out via **LinkedIn**.

---

🚀 **Maximize your Linux performance with Tuned Optimizer!**
