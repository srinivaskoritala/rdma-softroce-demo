#!/bin/bash

# RDMA Tools Demonstration Script
# Shows all available RDMA tools and their usage

echo "=========================================="
echo "RDMA Tools Demonstration"
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

print_header "1. Available RDMA Performance Tools"
print_status "Listing all available RDMA testing tools..."

tools=(
    "ib_write_bw:RDMA write bandwidth test"
    "ib_read_bw:RDMA read bandwidth test"
    "ib_send_bw:RDMA send bandwidth test"
    "ib_write_lat:RDMA write latency test"
    "ib_read_lat:RDMA read latency test"
    "ib_send_lat:RDMA send latency test"
    "ib_atomic_bw:RDMA atomic bandwidth test"
    "ib_atomic_lat:RDMA atomic latency test"
)

for tool_info in "${tools[@]}"; do
    tool_name=$(echo "$tool_info" | cut -d':' -f1)
    tool_desc=$(echo "$tool_info" | cut -d':' -f2)
    
    if command -v "$tool_name" &> /dev/null; then
        print_success "$tool_name"
        echo "  Description: $tool_desc"
        echo "  Location: $(which "$tool_name")"
        echo "  Usage: $tool_name [options]"
        echo
    else
        print_warning "$tool_name not found"
    fi
done

print_header "2. RDMA Diagnostic Tools"
print_status "Listing RDMA diagnostic and management tools..."

diag_tools=(
    "ibstat:Show InfiniBand device status"
    "ibstatus:Show InfiniBand device status (alternative)"
    "ibv_devices:List RDMA devices"
    "ibv_devinfo:Show RDMA device information"
    "ibping:Test RDMA connectivity"
    "ibdiagnet:InfiniBand diagnostic tool"
    "ibnetdiscover:Discover InfiniBand topology"
    "iblinkinfo:Show InfiniBand link information"
)

for tool_info in "${diag_tools[@]}"; do
    tool_name=$(echo "$tool_info" | cut -d':' -f1)
    tool_desc=$(echo "$tool_info" | cut -d':' -f2)
    
    if command -v "$tool_name" &> /dev/null; then
        print_success "$tool_name"
        echo "  Description: $tool_desc"
        echo "  Location: $(which "$tool_name")"
        echo
    else
        print_warning "$tool_name not found"
    fi
done

print_header "3. RDMA Performance Test Examples"
print_status "Showing example usage of RDMA performance tools..."

echo "Bandwidth Tests:"
echo "  # Write bandwidth test (4KB messages, 1000 iterations)"
echo "  ib_write_bw -d rxe0 -s 4K -n 1000"
echo
echo "  # Read bandwidth test (1MB messages, 100 iterations)"
echo "  ib_read_bw -d rxe0 -s 1M -n 100"
echo
echo "  # Send bandwidth test (64B messages, 10000 iterations)"
echo "  ib_send_bw -d rxe0 -s 64 -n 10000"
echo

echo "Latency Tests:"
echo "  # Write latency test (64B messages, 1000 iterations)"
echo "  ib_write_lat -d rxe0 -s 64 -n 1000"
echo
echo "  # Read latency test (1KB messages, 1000 iterations)"
echo "  ib_read_lat -d rxe0 -s 1K -n 1000"
echo
echo "  # Send latency test (32B messages, 1000 iterations)"
echo "  ib_send_lat -d rxe0 -s 32 -n 1000"
echo

echo "Atomic Tests:"
echo "  # Atomic bandwidth test (8B operations, 1000 iterations)"
echo "  ib_atomic_bw -d rxe0 -s 8 -n 1000"
echo
echo "  # Atomic latency test (8B operations, 1000 iterations)"
echo "  ib_atomic_lat -d rxe0 -s 8 -n 1000"
echo

print_header "4. RDMA Transport Types"
print_status "Available RDMA transport types and their usage..."

echo "RC (Reliable Connection):"
echo "  - Guaranteed delivery and ordering"
echo "  - Best for: Critical data transfers"
echo "  - Usage: ib_write_bw -t RC"
echo

echo "UC (Unreliable Connection):"
echo "  - No delivery guarantees, but maintains ordering"
echo "  - Best for: High-performance streaming"
echo "  - Usage: ib_write_bw -t UC"
echo

echo "UD (Unreliable Datagram):"
echo "  - Datagram-based, no connection state"
echo "  - Best for: Multicast, discovery protocols"
echo "  - Usage: ib_send_bw -t UD"
echo

echo "XRC (eXtended Reliable Connection):"
echo "  - Shared receive queues for scalability"
echo "  - Best for: Large-scale applications"
echo "  - Usage: ib_write_bw -t XRC"
echo

print_header "5. RDMA Test Parameters"
print_status "Common parameters for RDMA performance tests..."

echo "Device Selection:"
echo "  -d <device>     : Specify RDMA device (e.g., rxe0, mlx5_0)"
echo "  -i <port>       : Specify port number (default: 1)"
echo

echo "Message Parameters:"
echo "  -s <size>       : Message size (e.g., 64, 1K, 4K, 1M)"
echo "  -n <iterations> : Number of iterations"
echo "  -t <transport>  : Transport type (RC, UC, UD, XRC)"
echo

echo "Performance Tuning:"
echo "  -q <qps>        : Queue pairs per server"
echo "  -c <connections>: Number of connections"
echo "  -p <port>       : Port number for server"
echo "  -x <threads>    : Number of threads"
echo

echo "Advanced Options:"
echo "  -R              : Use RDMA read instead of write"
echo "  -a              : Use atomic operations"
echo "  -b              : Use bidirectional test"
echo "  -e              : Use event-driven mode"
echo

print_header "6. SoftRoCE Setup Commands"
print_status "Complete SoftRoCE setup and testing workflow..."

echo "Step 1: Install RDMA software"
echo "  sudo apt update"
echo "  sudo apt install -y rdma-core infiniband-diags perftest"
echo

echo "Step 2: Load SoftRoCE kernel modules"
echo "  sudo modprobe rxe"
echo "  sudo modprobe rdma_rxe"
echo "  sudo modprobe ib_core"
echo "  sudo modprobe ib_uverbs"
echo

echo "Step 3: Create SoftRoCE device"
echo "  sudo rdma link add rxe0 type rxe netdev eth0"
echo "  sudo rdma link set rxe0 state ACTIVE"
echo

echo "Step 4: Verify SoftRoCE setup"
echo "  ibv_devices                    # List RDMA devices"
echo "  ibstat rxe0                    # Device status"
echo "  ibv_devinfo -d rxe0           # Device information"
echo

echo "Step 5: Test SoftRoCE performance"
echo "  # Server side"
echo "  ib_write_bw -d rxe0 -s 4K -n 1000"
echo
echo "  # Client side"
echo "  ib_write_bw -d rxe0 -s 4K -n 1000 <server_ip>"
echo

print_header "7. Performance Benchmarking"
print_status "Example performance benchmarking scenarios..."

echo "Scenario 1: Basic Bandwidth Test"
echo "  Server: ib_write_bw -d rxe0 -s 4K -n 1000 -t RC"
echo "  Client: ib_write_bw -d rxe0 -s 4K -n 1000 -t RC <server_ip>"
echo "  Expected: 10-40 Gbps (depending on hardware)"
echo

echo "Scenario 2: Latency Test"
echo "  Server: ib_write_lat -d rxe0 -s 64 -n 1000 -t RC"
echo "  Client: ib_write_lat -d rxe0 -s 64 -n 1000 -t RC <server_ip>"
echo "  Expected: 1-5 μs (depending on hardware)"
echo

echo "Scenario 3: Message Rate Test"
echo "  Server: ib_send_bw -d rxe0 -s 64 -n 10000 -t RC"
echo "  Client: ib_send_bw -d rxe0 -s 64 -n 10000 -t RC <server_ip>"
echo "  Expected: 1-10M messages/sec"
echo

echo "Scenario 4: Multi-threaded Test"
echo "  Server: ib_write_bw -d rxe0 -s 4K -n 1000 -x 4"
echo "  Client: ib_write_bw -d rxe0 -s 4K -n 1000 -x 4 <server_ip>"
echo "  Expected: Higher throughput with multiple threads"
echo

print_header "8. Troubleshooting Commands"
print_status "Common troubleshooting commands for RDMA/SoftRoCE..."

echo "Check RDMA devices:"
echo "  ibv_devices                    # List available devices"
echo "  ibstat                         # Show device status"
echo "  ibv_devinfo -d rxe0           # Device details"
echo

echo "Check kernel modules:"
echo "  lsmod | grep rxe               # Check SoftRoCE modules"
echo "  lsmod | grep rdma              # Check RDMA modules"
echo "  modinfo rxe                    # Module information"
echo

echo "Check network configuration:"
echo "  ip link show                   # Network interfaces"
echo "  rdma link show                 # RDMA links"
echo "  ethtool -i eth0                # Interface information"
echo

echo "Check system logs:"
echo "  dmesg | grep -i rdma           # RDMA-related messages"
echo "  journalctl -u rdma             # RDMA service logs"
echo "  cat /var/log/syslog | grep rdma # System log RDMA messages"
echo

echo "Performance monitoring:"
echo "  htop                           # CPU usage"
echo "  iostat -x 1                    # I/O statistics"
echo "  netstat -i                     # Network statistics"
echo

print_header "9. SoftRoCE vs Hardware RDMA"
print_status "Comparison between SoftRoCE and hardware RDMA..."

echo "SoftRoCE (Software RDMA):"
echo "  ✓ No special hardware required"
echo "  ✓ Works with standard Ethernet"
echo "  ✓ Good for development and testing"
echo "  ✓ Lower performance than hardware"
echo "  ✓ Higher CPU usage"
echo

echo "Hardware RDMA (Mellanox, etc.):"
echo "  ✓ Hardware offload"
echo "  ✓ Lower latency"
echo "  ✓ Higher bandwidth"
echo "  ✓ Lower CPU usage"
echo "  ✗ Requires special hardware"
echo "  ✗ More expensive"
echo

print_header "10. Use Cases and Applications"
print_status "Common applications for RDMA/SoftRoCE..."

echo "High-Performance Computing:"
echo "  - MPI (Message Passing Interface)"
echo "  - OpenMPI, MPICH implementations"
echo "  - Parallel file systems (Lustre, GPFS)"
echo "  - Scientific computing frameworks"
echo

echo "Storage Systems:"
echo "  - NVMe over Fabrics (NVMe-oF)"
echo "  - Distributed storage systems"
echo "  - Database clustering"
echo "  - Object storage systems"
echo

echo "Machine Learning:"
echo "  - Distributed training"
echo "  - Parameter server architectures"
echo "  - Gradient synchronization"
echo "  - Model parallelism"
echo

echo "Cloud Computing:"
echo "  - Container networking"
echo "  - Microservices communication"
echo "  - Serverless computing"
echo "  - Edge computing"
echo

print_header "Demo Complete"
print_success "RDMA tools demonstration completed successfully!"
print_status "This demo showed:"
echo "  ✓ Available RDMA performance tools"
echo "  ✓ Diagnostic and management tools"
echo "  ✓ Example usage and parameters"
echo "  ✓ Transport types and options"
echo "  ✓ Setup and configuration"
echo "  ✓ Performance benchmarking"
echo "  ✓ Troubleshooting commands"
echo "  ✓ Use cases and applications"
echo
print_warning "Note: Actual RDMA functionality requires:"
echo "  - RDMA hardware or SoftRoCE setup"
echo "  - Two machines for performance testing"
echo "  - Proper network configuration"
echo "  - Kernel with RDMA support"
