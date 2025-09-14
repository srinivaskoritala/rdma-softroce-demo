#!/bin/bash

# Setup script for C2 instance with RDMA application
# Run this on your C2 instance after confirming RDMA is available

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                C2 Instance RDMA Setup                       ║"
echo "║                    $(date)                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "1. Updating system packages..."
sudo apt-get update -y

echo ""
echo "2. Installing RDMA dependencies..."
sudo apt-get install -y \
    build-essential \
    gcc \
    make \
    pkg-config \
    libibverbs-dev \
    librdmacm-dev \
    tcpdump \
    tshark \
    python3 \
    python3-pip \
    python3-psutil \
    bc \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    iputils-ping \
    infiniband-diags \
    rdma-core \
    libibverbs1 \
    librdmacm1

echo ""
echo "3. Installing Python dependencies..."
pip3 install --user psutil

echo ""
echo "4. Checking RDMA status..."
echo "InfiniBand devices:"
ls -la /sys/class/infiniband/ 2>/dev/null || echo "No InfiniBand devices found"

echo ""
echo "RDMA tools:"
which ibv_devices ibv_devinfo 2>/dev/null || echo "RDMA tools not found"

echo ""
echo "5. Loading RDMA modules (if needed)..."
sudo modprobe ib_core ib_uverbs rdma_cm 2>/dev/null || echo "Modules already loaded or not available"

echo ""
echo "6. Checking network interfaces..."
ip link show | grep -E "eth|en|ib"

echo ""
echo "7. Creating RDMA application directory..."
mkdir -p ~/rdma-app
cd ~/rdma-app

echo ""
echo "8. Setup complete! Next steps:"
echo "   - Upload your RDMA application files to ~/rdma-app/"
echo "   - Run: make all"
echo "   - Run: ./demo_simple.sh"
echo "   - Run: sudo ./run_test.sh"

echo ""
echo "9. Quick RDMA test:"
if command -v ibv_devices &>/dev/null; then
    echo "Running ibv_devices:"
    ibv_devices
else
    echo "ibv_devices not available"
fi

echo ""
echo "Setup completed at: $(date)"
