#!/bin/bash

# SoftRoCE (Software RDMA over Converged Ethernet) Demonstration Script
# This script demonstrates SoftRoCE setup and testing procedures

echo "=========================================="
echo "SoftRoCE (Software RDMA) Demonstration"
echo "=========================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "1. Checking System Information"
echo "=============================="
print_status "Kernel version: $(uname -r)"
print_status "OS: $(lsb_release -d | cut -f2)"
print_status "Architecture: $(uname -m)"
echo

echo "2. Checking RDMA Software Stack"
echo "==============================="
print_status "Checking for RDMA core utilities..."

# Check if RDMA tools are available
if command -v ib_write_bw &> /dev/null; then
    print_success "RDMA performance tools are available"
    echo "Available tools:"
    ls /usr/bin/ib_* 2>/dev/null | sed 's/^/  - /'
else
    print_warning "RDMA performance tools not found"
fi

if [ -f "/usr/sbin/ibstat" ]; then
    print_success "RDMA diagnostic tools are available"
else
    print_warning "RDMA diagnostic tools not found"
fi
echo

echo "3. Checking for RDMA Kernel Modules"
echo "==================================="
print_status "Checking for SoftRoCE kernel modules..."

# Check for RDMA modules
if lsmod | grep -q rxe; then
    print_success "SoftRoCE (rxe) module is loaded"
    lsmod | grep rxe
else
    print_warning "SoftRoCE (rxe) module not loaded"
    print_status "In a real setup, you would run: sudo modprobe rxe"
fi

if lsmod | grep -q rdma; then
    print_success "RDMA core modules are loaded"
    lsmod | grep rdma
else
    print_warning "RDMA core modules not loaded"
fi
echo

echo "4. Checking for RDMA Devices"
echo "============================"
print_status "Checking for InfiniBand/RDMA devices..."

if [ -d "/sys/class/infiniband" ]; then
    print_success "RDMA device directory exists"
    ls -la /sys/class/infiniband/
else
    print_warning "No RDMA devices found (expected in cloud environment)"
    print_status "In a real setup with SoftRoCE, you would see devices like:"
    echo "  - rxe0 (SoftRoCE device)"
    echo "  - mlx5_0 (Mellanox hardware device)"
fi
echo

echo "5. SoftRoCE Configuration (Simulated)"
echo "====================================="
print_status "Simulating SoftRoCE configuration steps..."

# Simulate SoftRoCE setup
echo "Step 1: Load SoftRoCE kernel modules"
echo "  sudo modprobe rxe"
echo "  sudo modprobe rdma_rxe"

echo "Step 2: Add network interface to SoftRoCE"
echo "  sudo rdma link add rxe0 type rxe netdev eth0"

echo "Step 3: Verify SoftRoCE device"
echo "  ibv_devices"
echo "  ibstat"
echo

echo "6. RDMA Performance Testing (Simulated)"
echo "======================================="
print_status "Simulating RDMA performance tests..."

# Show what the performance tests would look like
echo "Available RDMA performance tools:"
echo "  - ib_write_bw: Write bandwidth test"
echo "  - ib_read_bw: Read bandwidth test"
echo "  - ib_send_bw: Send bandwidth test"
echo "  - ib_write_lat: Write latency test"
echo "  - ib_read_lat: Read latency test"
echo "  - ib_send_lat: Send latency test"
echo

echo "Example usage (requires two machines with RDMA):"
echo "  Server: ib_write_bw -d rxe0 -s 4K -n 1000"
echo "  Client: ib_write_bw -d rxe0 -s 4K -n 1000 <server_ip>"
echo

echo "7. SoftRoCE Benefits Demonstration"
echo "=================================="
print_status "SoftRoCE provides the following benefits:"
echo "  ✓ Zero-copy data transfers"
echo "  ✓ Kernel bypass for low latency"
echo "  ✓ High bandwidth utilization"
echo "  ✓ CPU offloading for network operations"
echo "  ✓ Compatible with existing RDMA applications"
echo "  ✓ No special hardware required"
echo

echo "8. Real-World SoftRoCE Setup Commands"
echo "====================================="
print_status "Complete SoftRoCE setup commands for a real system:"
echo
echo "# Install required packages"
echo "sudo apt update"
echo "sudo apt install -y rdma-core infiniband-diags perftest"
echo
echo "# Load kernel modules"
echo "sudo modprobe rxe"
echo "sudo modprobe rdma_rxe"
echo
echo "# Add network interface to SoftRoCE"
echo "sudo rdma link add rxe0 type rxe netdev eth0"
echo
echo "# Verify setup"
echo "ibv_devices"
echo "ibstat"
echo
echo "# Test performance"
echo "ib_write_bw -d rxe0"
echo

echo "9. Performance Comparison"
echo "========================="
print_status "Typical performance characteristics:"
echo "  Traditional TCP/IP:"
echo "    - Latency: 10-50 μs"
echo "    - Bandwidth: Limited by CPU"
echo "    - CPU Usage: High"
echo
echo "  SoftRoCE:"
echo "    - Latency: 5-20 μs"
echo "    - Bandwidth: Near line rate"
echo "    - CPU Usage: Low"
echo

echo "10. Troubleshooting Tips"
echo "========================"
print_status "Common SoftRoCE troubleshooting steps:"
echo "  1. Check kernel module loading: lsmod | grep rxe"
echo "  2. Verify device creation: ibv_devices"
echo "  3. Check network interface: ip link show"
echo "  4. Verify RDMA link: rdma link show"
echo "  5. Test connectivity: ibping"
echo

echo "=========================================="
echo "SoftRoCE Demonstration Complete"
echo "=========================================="
print_success "This demonstration showed SoftRoCE concepts and setup procedures"
print_status "For actual SoftRoCE functionality, you need:"
echo "  - A physical machine (not cloud instance)"
echo "  - Kernel with RDMA support"
echo "  - Network interface suitable for RDMA"
echo "  - Two machines for performance testing"
