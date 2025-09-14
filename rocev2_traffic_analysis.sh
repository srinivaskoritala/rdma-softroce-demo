#!/bin/bash

# RoCEv2 Traffic Analysis and Simulation
# This script demonstrates RoCEv2 (RDMA over Converged Ethernet v2) traffic patterns

echo "=========================================="
echo "RoCEv2 Traffic Analysis and Simulation"
echo "=========================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}$1${NC}"
    echo "$(printf '=%.0s' {1..60})"
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

print_rocev2() {
    echo -e "${MAGENTA}[RoCEv2]${NC} $1"
}

print_header "1. RoCEv2 vs RoCEv1 vs InfiniBand"
print_status "Understanding the differences between RDMA protocols:"

echo "InfiniBand (Native):"
echo "  - Protocol: InfiniBand fabric"
echo "  - Port: N/A (fabric-based)"
echo "  - Headers: InfiniBand only"
echo "  - Performance: Highest (hardware offload)"
echo "  - Use Case: HPC clusters, data centers"
echo

print_rocev2 "RoCEv1 (RDMA over Converged Ethernet v1):"
echo "  - Protocol: InfiniBand over Ethernet (lossless)"
echo "  - Port: 18515 (standard)"
echo "  - Headers: Ethernet + InfiniBand"
echo "  - Performance: High (requires lossless Ethernet)"
echo "  - Use Case: Data center networks with PFC"
echo

print_rocev2 "RoCEv2 (RDMA over Converged Ethernet v2):"
echo "  - Protocol: InfiniBand over UDP/IP"
echo "  - Port: 4791 (standard)"
echo "  - Headers: Ethernet + IP + UDP + InfiniBand"
echo "  - Performance: High (works with standard Ethernet)"
echo "  - Use Case: Cloud, standard Ethernet networks"
echo

print_header "2. RoCEv2 Packet Structure"
print_status "Detailed RoCEv2 packet format:"

echo "Ethernet Header (14 bytes):"
echo "  | Dest MAC (6) | Src MAC (6) | EtherType (2) |"
echo "  | 0x02:00:00:00:00:02 | 0x02:00:00:00:00:01 | 0x0800 (IPv4) |"
echo

echo "IPv4 Header (20 bytes):"
echo "  | Version (4) | IHL (4) | TOS (8) | Total Length (16) |"
echo "  | Identification (16) | Flags (3) | Fragment Offset (13) |"
echo "  | TTL (8) | Protocol (8) | Header Checksum (16) |"
echo "  | Source IP (32) | Destination IP (32) |"
echo "  | Source: 192.168.1.10 | Dest: 192.168.1.20 |"
echo

echo "UDP Header (8 bytes):"
echo "  | Source Port (16) | Destination Port (16) |"
echo "  | Length (16) | Checksum (16) |"
echo "  | Source: 4791 | Dest: 4791 |"
echo

echo "InfiniBand Headers (60+ bytes):"
echo "  | LRH (8) | GRH (40) | BTH (12) | DETH/RETH/AETH (8-16) | Payload | ICRC (4) |"
echo

print_header "3. RoCEv2 Operation Types"
print_status "RoCEv2 supports all standard RDMA operations:"

print_rocev2 "RDMA Write Operations:"
echo "  - Opcode: 0x08 (RDMA Write)"
echo "  - Headers: BTH + RETH"
echo "  - Flow: Client -> Server (one-way)"
echo "  - Use Case: Bulk data transfer, zero-copy"
echo

print_rocev2 "RDMA Read Operations:"
echo "  - Opcode: 0x08 (Read Request), 0x09 (Read Response)"
echo "  - Headers: BTH + RETH"
echo "  - Flow: Request/Response"
echo "  - Use Case: Remote memory access"
echo

print_rocev2 "Send/Receive Operations:"
echo "  - Opcode: 0x04 (Send)"
echo "  - Headers: BTH + DETH"
echo "  - Flow: Bidirectional"
echo "  - Use Case: Message passing, RPC"
echo

print_rocev2 "Atomic Operations:"
echo "  - Opcode: 0x0F (C&S), 0x10 (Atomic Response)"
echo "  - Headers: BTH + AETH"
echo "  - Flow: Request/Response"
echo "  - Use Case: Synchronization, counters"
echo

print_rocev2 "Control Operations:"
echo "  - Opcode: 0x60 (ACK), 0x20 (NAK), 0x80 (CNP)"
echo "  - Headers: BTH + Extended headers"
echo "  - Flow: Bidirectional"
echo "  - Use Case: Flow control, congestion control"
echo

print_header "4. RoCEv2 Traffic Capture Commands"
print_status "Commands to capture and analyze RoCEv2 traffic:"

echo "Basic RoCEv2 Capture:"
echo "  sudo tcpdump -i eth0 -w rocev2.pcap port 4791"
echo

echo "Filter Specific Operations:"
echo "  # RDMA Write operations"
echo "  sudo tcpdump -i eth0 'port 4791 and udp[20:4] = 0x08'"
echo
echo "  # Send operations"
echo "  sudo tcpdump -i eth0 'port 4791 and udp[20:4] = 0x04'"
echo
echo "  # Atomic operations"
echo "  sudo tcpdump -i eth0 'port 4791 and udp[20:4] = 0x0F'"
echo

echo "Advanced Filtering:"
echo "  # Specific hosts"
echo "  sudo tcpdump -i eth0 'host 192.168.1.10 and port 4791'"
echo
echo "  # Large packets (RDMA Write)"
echo "  sudo tcpdump -i eth0 'port 4791 and length > 1000'"
echo
echo "  # Small packets (control messages)"
echo "  sudo tcpdump -i eth0 'port 4791 and length < 100'"
echo

print_header "5. RoCEv2 Performance Characteristics"
print_status "RoCEv2 performance compared to other protocols:"

echo "Latency Comparison:"
echo "  InfiniBand:     0.5-1.0 μs"
echo "  RoCEv1:         1-2 μs"
echo "  RoCEv2:         2-5 μs"
echo "  TCP/IP:         10-50 μs"
echo

echo "Bandwidth Comparison:"
echo "  InfiniBand:     200-400 Gbps"
echo "  RoCEv1:         100-200 Gbps"
echo "  RoCEv2:         50-100 Gbps"
echo "  TCP/IP:         1-10 Gbps"
echo

echo "CPU Usage:"
echo "  InfiniBand:     < 1%"
echo "  RoCEv1:         1-5%"
echo "  RoCEv2:         5-15%"
echo "  TCP/IP:         50-80%"
echo

print_header "6. RoCEv2 Configuration"
print_status "Setting up RoCEv2 on Linux systems:"

echo "Load RoCEv2 kernel modules:"
echo "  sudo modprobe rdma_rxe"
echo "  sudo modprobe rxe"
echo

echo "Create RoCEv2 device:"
echo "  sudo rdma link add rxe0 type rxe netdev eth0"
echo "  sudo rdma link set rxe0 state ACTIVE"
echo

echo "Verify RoCEv2 setup:"
echo "  ibv_devices"
echo "  ibstat rxe0"
echo "  ibv_devinfo -d rxe0"
echo

echo "Test RoCEv2 performance:"
echo "  ib_write_bw -d rxe0 -s 4K -n 1000"
echo "  ib_write_lat -d rxe0 -s 64 -n 1000"
echo

print_header "7. RoCEv2 Traffic Patterns"
print_status "Common RoCEv2 traffic patterns in applications:"

print_rocev2 "High-Performance Computing:"
echo "  - Bulk data transfers (RDMA Write)"
echo "  - Collective operations (Send/Receive)"
echo "  - Synchronization (Atomic operations)"
echo "  - Pattern: Burst traffic during computation"
echo

print_rocev2 "Storage Systems (NVMe-oF):"
echo "  - Large block transfers (RDMA Write/Read)"
echo "  - Command processing (Send/Receive)"
echo "  - Status updates (Atomic operations)"
echo "  - Pattern: Sustained high bandwidth"
echo

print_rocev2 "Machine Learning:"
echo "  - Gradient updates (RDMA Write)"
echo "  - Parameter synchronization (Atomic)"
echo "  - Model broadcasting (Send/Receive)"
echo "  - Pattern: Periodic synchronization"
echo

print_rocev2 "Cloud Computing:"
echo "  - Container networking (Send/Receive)"
echo "  - Microservices communication (RDMA Write)"
echo "  - Serverless computing (Atomic operations)"
echo "  - Pattern: Mixed traffic types"
echo

print_header "8. RoCEv2 Troubleshooting"
print_status "Common RoCEv2 issues and solutions:"

echo "Connection Issues:"
echo "  - Check UDP port 4791: netstat -ulnp | grep 4791"
echo "  - Verify RoCEv2 device: ibv_devices"
echo "  - Check queue pair state: ibv_devinfo -d rxe0"
echo

echo "Performance Issues:"
echo "  - Monitor packet drops: ibstat rxe0"
echo "  - Check CPU usage: htop"
echo "  - Analyze network utilization: ethtool -S eth0"
echo

echo "Traffic Analysis:"
echo "  - Capture RoCEv2 traffic: tcpdump -i eth0 port 4791"
echo "  - Filter by operation: tcpdump 'port 4791 and udp[20:4] = 0x08'"
echo "  - Monitor timing: tcpdump -tt 'port 4791'"
echo

print_header "9. RoCEv2 vs Other Protocols"
print_status "Protocol comparison for different use cases:"

echo "Use Case: High-Performance Computing"
echo "  Best Choice: InfiniBand (if available)"
echo "  Alternative: RoCEv2 (if Ethernet only)"
echo "  Avoid: TCP/IP (too slow)"
echo

echo "Use Case: Cloud Computing"
echo "  Best Choice: RoCEv2 (works with standard Ethernet)"
echo "  Alternative: RoCEv1 (if lossless Ethernet available)"
echo "  Fallback: TCP/IP (if RDMA not available)"
echo

echo "Use Case: Storage Systems"
echo "  Best Choice: RoCEv2 (good balance of performance/compatibility)"
echo "  Alternative: InfiniBand (if available)"
echo "  Fallback: TCP/IP (if RDMA not available)"
echo

print_header "10. RoCEv2 Monitoring Tools"
print_status "Tools for monitoring RoCEv2 performance:"

echo "RDMA-specific Tools:"
echo "  - ibstat: Device statistics"
echo "  - ibv_devinfo: Device information"
echo "  - ibv_devices: List devices"
echo "  - ibping: Connectivity test"
echo

echo "Network Analysis Tools:"
echo "  - tcpdump: Packet capture"
echo "  - wireshark: Protocol analysis"
echo "  - ethtool: Interface statistics"
echo "  - netstat: Network connections"
echo

echo "Performance Monitoring:"
echo "  - htop: CPU usage"
echo "  - iostat: I/O statistics"
echo "  - perf: CPU performance analysis"
echo "  - sar: System activity report"
echo

print_header "Demo Complete"
print_success "RoCEv2 traffic analysis and simulation completed!"

print_status "Files created:"
echo "  - rocev2_traffic_simulation.txt: Detailed RoCEv2 packet examples"
echo "  - This demonstration: Complete RoCEv2 analysis"

print_rocev2 "RoCEv2 provides:"
echo "  ✓ High performance over standard Ethernet"
echo "  ✓ No need for lossless Ethernet (unlike RoCEv1)"
echo "  ✓ Works in cloud environments"
echo "  ✓ Compatible with existing RDMA applications"
echo "  ✓ Good balance of performance and compatibility"
echo "  ✓ Standard UDP port 4791"
