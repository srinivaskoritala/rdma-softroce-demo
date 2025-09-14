#!/bin/bash

# Advanced RDMA/SoftRoCE Technical Demonstration
# This script shows detailed RDMA capabilities and testing

echo "=========================================="
echo "Advanced RDMA/SoftRoCE Technical Demo"
echo "=========================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}$1${NC}"
    echo "$(printf '=%.0s' {1..50})"
}

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

print_header "1. RDMA Software Stack Analysis"
print_status "Checking RDMA library versions and capabilities..."

# Check RDMA library versions
if [ -f "/usr/lib/x86_64-linux-gnu/libibverbs.so.1" ]; then
    print_success "libibverbs library found"
    echo "  Version: $(readlink /usr/lib/x86_64-linux-gnu/libibverbs.so.1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')"
fi

if [ -f "/usr/lib/x86_64-linux-gnu/librdmacm.so.1" ]; then
    print_success "librdmacm library found"
    echo "  Version: $(readlink /usr/lib/x86_64-linux-gnu/librdmacm.so.1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')"
fi

echo

print_header "2. RDMA Performance Tools Analysis"
print_status "Analyzing available RDMA performance testing tools..."

# Show detailed information about each tool
tools=("ib_write_bw" "ib_read_bw" "ib_send_bw" "ib_write_lat" "ib_read_lat" "ib_send_lat" "ib_atomic_bw" "ib_atomic_lat")

for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        print_success "$tool is available"
        echo "  Purpose: $(man -f "$tool" 2>/dev/null | head -1 | cut -d'-' -f2- | xargs || echo "RDMA performance testing tool")"
        echo "  Location: $(which "$tool")"
    else
        print_warning "$tool not found"
    fi
done

echo

print_header "3. RDMA Transport Types"
print_status "SoftRoCE supports multiple RDMA transport types:"

echo "  RC (Reliable Connection):"
echo "    - Guaranteed delivery and ordering"
echo "    - Used for: Critical data transfers"
echo "    - Example: ib_write_bw -t RC"

echo "  UC (Unreliable Connection):"
echo "    - No delivery guarantees"
echo "    - Used for: High-performance streaming"
echo "    - Example: ib_write_bw -t UC"

echo "  UD (Unreliable Datagram):"
echo "    - Datagram-based, no connection"
echo "    - Used for: Multicast, discovery"
echo "    - Example: ib_send_bw -t UD"

echo "  XRC (eXtended Reliable Connection):"
echo "    - Shared receive queues"
echo "    - Used for: Scalable applications"
echo "    - Example: ib_write_bw -t XRC"

echo

print_header "4. RDMA Operation Types"
print_status "SoftRoCE supports various RDMA operations:"

echo "  Send/Receive Operations:"
echo "    - ib_send_bw: Send bandwidth test"
echo "    - ib_send_lat: Send latency test"
echo "    - Used for: Message passing, RPC"

echo "  RDMA Write Operations:"
echo "    - ib_write_bw: Write bandwidth test"
echo "    - ib_write_lat: Write latency test"
echo "    - Used for: Bulk data transfer, zero-copy"

echo "  RDMA Read Operations:"
echo "    - ib_read_bw: Read bandwidth test"
echo "    - ib_read_lat: Read latency test"
echo "    - Used for: Remote memory access"

echo "  Atomic Operations:"
echo "    - ib_atomic_bw: Atomic bandwidth test"
echo "    - ib_atomic_lat: Atomic latency test"
echo "    - Used for: Synchronization, counters"

echo

print_header "5. SoftRoCE Configuration Simulation"
print_status "Simulating complete SoftRoCE setup process..."

echo "Step 1: Check system prerequisites"
echo "  - Kernel version: $(uname -r)"
echo "  - RDMA modules available: $(ls /lib/modules/$(uname -r)/kernel/drivers/infiniband/ 2>/dev/null | wc -l) modules"
echo "  - Network interfaces: $(ip link show | grep -c '^[0-9]')"

echo
echo "Step 2: Load SoftRoCE kernel modules (simulated)"
echo "  sudo modprobe rxe                    # SoftRoCE core module"
echo "  sudo modprobe rdma_rxe              # RDMA transport"
echo "  sudo modprobe ib_core               # InfiniBand core"
echo "  sudo modprobe ib_uverbs             # User verbs interface"

echo
echo "Step 3: Create SoftRoCE device (simulated)"
echo "  sudo rdma link add rxe0 type rxe netdev eth0"
echo "  sudo rdma link set rxe0 state ACTIVE"

echo
echo "Step 4: Verify SoftRoCE device (simulated)"
echo "  ibv_devices                          # List RDMA devices"
echo "  ibstat rxe0                          # Device statistics"
echo "  ibv_devinfo -d rxe0                 # Device information"

echo

print_header "6. Performance Testing Scenarios"
print_status "Simulating various RDMA performance test scenarios..."

echo "Scenario 1: Bandwidth Testing"
echo "  Server: ib_write_bw -d rxe0 -s 4K -n 1000 -t RC"
echo "  Client: ib_write_bw -d rxe0 -s 4K -n 1000 -t RC <server_ip>"
echo "  Expected: ~10-40 Gbps (depending on hardware)"

echo
echo "Scenario 2: Latency Testing"
echo "  Server: ib_write_lat -d rxe0 -s 64 -n 1000 -t RC"
echo "  Client: ib_write_lat -d rxe0 -s 64 -n 1000 -t RC <server_ip>"
echo "  Expected: ~1-5 μs (depending on hardware)"

echo
echo "Scenario 3: Message Rate Testing"
echo "  Server: ib_send_bw -d rxe0 -s 64 -n 10000 -t RC"
echo "  Client: ib_send_bw -d rxe0 -s 64 -n 10000 -t RC <server_ip>"
echo "  Expected: ~1-10M messages/sec"

echo
echo "Scenario 4: Memory Registration Testing"
echo "  ibv_rc_pingpong -d rxe0 -s 1M -n 1000"
echo "  Tests memory registration overhead"

echo

print_header "7. SoftRoCE vs Hardware RDMA Comparison"
print_status "Performance characteristics comparison:"

echo "Hardware RDMA (Mellanox ConnectX-6):"
echo "  - Latency: 0.5-1.0 μs"
echo "  - Bandwidth: 200-400 Gbps"
echo "  - CPU Usage: < 1%"
echo "  - Memory: Hardware offload"

echo
echo "SoftRoCE (Software implementation):"
echo "  - Latency: 2-10 μs"
echo "  - Bandwidth: 10-40 Gbps"
echo "  - CPU Usage: 10-30%"
echo "  - Memory: Software implementation"

echo
echo "Traditional TCP/IP:"
echo "  - Latency: 10-50 μs"
echo "  - Bandwidth: 1-10 Gbps"
echo "  - CPU Usage: 50-80%"
echo "  - Memory: Kernel buffers"

echo

print_header "8. RDMA Application Development"
print_status "Key concepts for RDMA application development:"

echo "Memory Management:"
echo "  - Memory Registration: ibv_reg_mr()"
echo "  - Memory Deregistration: ibv_dereg_mr()"
echo "  - Memory Regions: Contiguous virtual memory"

echo
echo "Queue Pairs:"
echo "  - Send Queue: Outgoing operations"
echo "  - Receive Queue: Incoming operations"
echo "  - Completion Queue: Operation completion"

echo
echo "Work Requests:"
echo "  - Send Work Request: ibv_post_send()"
echo "  - Receive Work Request: ibv_post_recv()"
echo "  - Completion Polling: ibv_poll_cq()"

echo

print_header "9. SoftRoCE Use Cases"
print_status "Common applications for SoftRoCE:"

echo "High-Performance Computing:"
echo "  - MPI implementations (OpenMPI, MPICH)"
echo "  - Parallel file systems (Lustre, GPFS)"
echo "  - Scientific computing frameworks"

echo
echo "Storage Systems:"
echo "  - NVMe over Fabrics (NVMe-oF)"
echo "  - Distributed storage systems"
echo "  - Database clustering"

echo
echo "Machine Learning:"
echo "  - Distributed training"
echo "  - Parameter server architectures"
echo "  - Gradient synchronization"

echo
echo "Cloud Computing:"
echo "  - Container networking"
echo "  - Microservices communication"
echo "  - Serverless computing"

echo

print_header "10. Troubleshooting and Optimization"
print_status "Common SoftRoCE issues and solutions:"

echo "Performance Issues:"
echo "  - Check CPU affinity: taskset -c 0-3 ib_write_bw"
echo "  - Verify NUMA locality: numactl --cpunodebind=0"
echo "  - Monitor CPU usage: htop, perf top"

echo
echo "Connectivity Issues:"
echo "  - Check network interface: ip link show"
echo "  - Verify RDMA link: rdma link show"
echo "  - Test basic connectivity: ping, ibping"

echo
echo "Configuration Issues:"
echo "  - Check kernel modules: lsmod | grep rxe"
echo "  - Verify device creation: ibv_devices"
echo "  - Check system logs: dmesg | grep -i rdma"

echo

print_header "11. Advanced SoftRoCE Features"
print_status "Advanced SoftRoCE capabilities:"

echo "Multi-Queue Support:"
echo "  - Multiple queue pairs per device"
echo "  - Load balancing across queues"
echo "  - NUMA-aware queue placement"

echo
echo "Memory Management:"
echo "  - Huge pages support"
echo "  - Memory pinning"
echo "  - Zero-copy operations"

echo
echo "Network Features:"
echo "  - Jumbo frames support"
echo "  - Flow control"
echo "  - Congestion control"

echo

print_header "12. Monitoring and Debugging"
print_status "Tools for monitoring SoftRoCE performance:"

echo "Performance Monitoring:"
echo "  - ibv_devinfo: Device information"
echo "  - ibstat: Device statistics"
echo "  - perf: CPU performance analysis"

echo
echo "Network Monitoring:"
echo "  - ethtool: Network interface statistics"
echo "  - netstat: Network connections"
echo "  - ss: Socket statistics"

echo
echo "System Monitoring:"
echo "  - htop: Process monitoring"
echo "  - iostat: I/O statistics"
echo "  - vmstat: Virtual memory statistics"

echo

print_header "Demo Complete"
print_success "SoftRoCE technical demonstration completed successfully!"
print_status "This demo showed:"
echo "  ✓ RDMA software stack analysis"
echo "  ✓ Performance testing tools"
echo "  ✓ Transport and operation types"
echo "  ✓ Configuration procedures"
echo "  ✓ Performance characteristics"
echo "  ✓ Application development concepts"
echo "  ✓ Use cases and troubleshooting"
echo
print_warning "Note: Actual SoftRoCE functionality requires:"
echo "  - Physical hardware (not cloud instance)"
echo "  - Kernel with RDMA support"
echo "  - Two machines for testing"
echo "  - Proper network configuration"
