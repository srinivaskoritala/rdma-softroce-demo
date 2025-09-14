# RDMA Application Setup Guide for macOS

## ❌ Native macOS Limitations

macOS **does not support RDMA** natively due to:
- No RDMA kernel support
- No InfiniBand drivers available
- No RoCE (RDMA over Converged Ethernet) support
- No iWARP support
- Major hardware vendors don't provide macOS RDMA drivers

## ✅ Alternative Solutions for Your Mac

### 1. 🐳 Docker with Linux Container (Recommended)

**Pros:** Easy setup, isolated environment, good performance
**Cons:** No real RDMA hardware access

```bash
# Install Docker Desktop for Mac
# https://www.docker.com/products/docker-desktop/

# Create Dockerfile for RDMA development
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

# Install RDMA dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libibverbs-dev \
    librdmacm-dev \
    tcpdump \
    tshark \
    python3 \
    python3-psutil \
    bc \
    pkg-config

WORKDIR /app
COPY . .

# Build the application
RUN make all

CMD ["/bin/bash"]
EOF

# Build and run the container
docker build -t rdma-app .
docker run -it --privileged --net=host rdma-app

# Inside container, run the demo
./demo_simple.sh
```

### 2. 🖥️ Virtual Machine (VMware/VirtualBox)

**Pros:** Full Linux environment, can simulate RDMA
**Cons:** Resource intensive, no real RDMA hardware

```bash
# Download Ubuntu 22.04 LTS
# https://ubuntu.com/download/desktop

# Install in VMware Fusion or VirtualBox
# Allocate: 4GB RAM, 2 CPU cores, 20GB disk

# After Linux installation:
sudo apt-get update
sudo apt-get install -y libibverbs-dev librdmacm-dev tcpdump tshark python3 python3-psutil bc pkg-config
make all
./demo_simple.sh
```

### 3. ☁️ Cloud Instance (Best for Real RDMA)

**Pros:** Access to real RDMA hardware, production-like environment
**Cons:** Costs money, requires cloud account

#### AWS EC2 with RDMA:
```bash
# Launch instance type: c5n.9xlarge or larger
# AMI: Amazon Linux 2 or Ubuntu 20.04/22.04
# Enable Enhanced Networking

# Connect via SSH
ssh -i your-key.pem ec2-user@your-instance-ip

# Install dependencies
sudo yum update -y
sudo yum install -y libibverbs-devel librdmacm-devel tcpdump wireshark python3 python3-psutil bc

# Upload and run the application
scp -r . ec2-user@your-instance-ip:~/rdma-app/
ssh ec2-user@your-instance-ip
cd rdma-app
make all
sudo ./run_test.sh
```

#### Google Cloud Platform:
```bash
# Create instance with RDMA support
gcloud compute instances create rdma-test \
    --zone=us-central1-a \
    --machine-type=c2-standard-16 \
    --enable-nested-virtualization \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud

# Connect and setup
gcloud compute ssh rdma-test --zone=us-central1-a
```

### 4. 🐧 Linux Dual Boot

**Pros:** Native Linux performance, full hardware access
**Cons:** Requires rebooting, disk space

```bash
# Download Ubuntu 22.04 LTS
# Create bootable USB with Balena Etcher
# Install alongside macOS (dual boot)

# After Linux installation:
sudo apt-get update
sudo apt-get install -y libibverbs-dev librdmacm-dev tcpdump tshark python3 python3-psutil bc pkg-config
make all
./demo_simple.sh
```

### 5. 📱 Remote Linux Server

**Pros:** No local setup, access to real hardware
**Cons:** Requires remote server, network dependency

```bash
# Rent a Linux VPS with RDMA support
# Examples: AWS, GCP, Azure, or specialized HPC providers

# Upload your code
scp -r . user@server-ip:~/rdma-app/

# Connect and run
ssh user@server-ip
cd rdma-app
make all
sudo ./run_test.sh
```

## 🎯 Recommended Approach

### For Development & Learning:
**Docker Container** - Easy to set up, good for code development

### For Real RDMA Testing:
**Cloud Instance** - Access to actual RDMA hardware

### For Production:
**Dedicated Linux Server** - Full control and performance

## 🚀 Quick Start with Docker

```bash
# 1. Install Docker Desktop for Mac
# 2. Clone the repository
git clone <your-repo> rdma-app
cd rdma-app

# 3. Create and run container
docker build -t rdma-app .
docker run -it --privileged --net=host rdma-app

# 4. Inside container
make all
./demo_simple.sh
```

## 📊 Performance Expectations

| Environment | RDMA Hardware | Performance | Use Case |
|-------------|---------------|-------------|----------|
| macOS Native | ❌ None | N/A | Not possible |
| Docker | ❌ Simulated | Low | Development |
| VM | ❌ Simulated | Medium | Testing |
| Cloud | ✅ Real | High | Production |
| Linux Native | ✅ Real | Highest | Production |

## 🔧 Troubleshooting

### Docker Issues:
```bash
# Enable privileged mode
docker run -it --privileged --net=host rdma-app

# Check network access
docker run -it --net=host rdma-app ping google.com
```

### VM Issues:
```bash
# Enable nested virtualization
# Allocate sufficient resources (4GB+ RAM)
# Use bridged networking
```

### Cloud Issues:
```bash
# Check instance type supports RDMA
# Verify Enhanced Networking is enabled
# Check security groups allow required ports
```

## 📚 Next Steps

1. **Choose your preferred method**
2. **Set up the environment**
3. **Upload the RDMA application code**
4. **Run the demo and tests**
5. **Analyze real RDMA packet captures**

The application is ready to run in any Linux environment - you just need to choose the best option for your needs!
