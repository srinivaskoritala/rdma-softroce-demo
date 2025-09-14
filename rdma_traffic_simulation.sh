#!/bin/bash

# RDMA Traffic Simulation and Visualization
# This script shows what RDMA traffic looks like and simulates RDMA packet structures

echo "=========================================="
echo "RDMA Traffic Simulation and Visualization"
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

print_rdma() {
    echo -e "${MAGENTA}[RDMA]${NC} $1"
}

print_header "1. RDMA Traffic Overview"
print_status "RDMA (Remote Direct Memory Access) traffic characteristics:"

echo "RDMA Protocol Stack:"
echo "  Application Layer    | RDMA Verbs API"
echo "  Transport Layer      | InfiniBand Transport (RC, UC, UD, XRC)"
echo "  Network Layer        | InfiniBand Network Layer"
echo "  Data Link Layer      | InfiniBand over Ethernet (RoCE)"
echo "  Physical Layer       | Ethernet (10/25/40/100 Gbps)"
echo

print_rdma "Key RDMA Traffic Features:"
echo "  ✓ Zero-copy data transfers"
echo "  ✓ Kernel bypass"
echo "  ✓ Hardware offload"
echo "  ✓ Low latency (μs range)"
echo "  ✓ High bandwidth (Gbps range)"
echo "  ✓ Reliable delivery (RC transport)"
echo

print_header "2. RDMA Packet Structure"
print_status "InfiniBand over Ethernet (RoCE) packet format:"

echo "Ethernet Header (14 bytes):"
echo "  | Destination MAC (6) | Source MAC (6) | EtherType (2) |"
echo "  | 0x02:00:00:00:00:01 | 0x02:00:00:00:00:02 | 0x8915 (RoCE) |"
echo

echo "InfiniBand Header (40 bytes):"
echo "  | LRH (8) | GRH (40) | BTH (12) | DETH (8) | RETH (16) | Payload | ICRC (4) |"
echo "  | Local Route Header | Global Route Header | Base Transport Header |"
echo "  | Data Extended Transport Header | RDMA Extended Transport Header |"
echo

echo "RDMA Operation Headers:"
echo "  Send/Receive:     | BTH | DETH | Payload |"
echo "  RDMA Write:       | BTH | RETH | Payload |"
echo "  RDMA Read:        | BTH | RETH | (no payload) |"
echo "  Atomic:           | BTH | AETH | (no payload) |"
echo

print_header "3. RDMA Traffic Types"
print_status "Different types of RDMA traffic patterns:"

print_rdma "1. RDMA Write Operations:"
echo "  Purpose: Direct memory-to-memory transfer"
echo "  Packet: | Ethernet | IB | BTH | RETH | Data |"
echo "  Flow:   Client -> Server (one-way data transfer)"
echo "  Size:   Variable (1B to 2GB per operation)"
echo

print_rdma "2. RDMA Read Operations:"
echo "  Purpose: Remote memory access"
echo "  Packet: | Ethernet | IB | BTH | RETH | (no data) |"
echo "  Flow:   Client -> Server (request), Server -> Client (response)"
echo "  Size:   Request: 28 bytes, Response: 28 + data bytes"
echo

print_rdma "3. Send/Receive Operations:"
echo "  Purpose: Message passing, RPC"
echo "  Packet: | Ethernet | IB | BTH | DETH | Message |"
echo "  Flow:   Bidirectional message exchange"
echo "  Size:   Variable (1B to 2GB per message)"
echo

print_rdma "4. Atomic Operations:"
echo "  Purpose: Synchronization, counters"
echo "  Packet: | Ethernet | IB | BTH | AETH | (no data) |"
echo "  Flow:   Client -> Server (operation), Server -> Client (result)"
echo "  Size:   Request: 28 bytes, Response: 28 + 8 bytes"
echo

print_header "4. Simulated RDMA Traffic Capture"
print_status "Creating simulated RDMA traffic patterns..."

# Create a simulated RDMA traffic capture
cat > /home/srini/ws/simulated_rdma_traffic.txt << 'EOF'
# Simulated RDMA Traffic Capture
# This shows what RDMA traffic would look like in a real environment

# RDMA Write Operation (4KB data transfer)
10:04:56.000001 IP 192.168.1.10.18515 > 192.168.1.20.18515: RoCE v2, length 4148
    InfiniBand: Local Route Header (8 bytes)
      Version: 0, Service Level: 0, Destination LID: 0x0001
      Packet Length: 4148, Source LID: 0x0002
    InfiniBand: Global Route Header (40 bytes)
      Version: 0, Traffic Class: 0, Flow Label: 0x000000
      Payload Length: 4100, Next Header: 0x1B, Hop Limit: 64
      Source GID: 192.168.1.10, Destination GID: 192.168.1.20
    InfiniBand: Base Transport Header (12 bytes)
      Opcode: RDMA Write (0x08), Solicited Event: 0, Migrated: 0
      Pad Count: 0, Transport Header Version: 0, Partition Key: 0x1234
      Destination Queue Pair: 0x0001, Packet Sequence Number: 0x00000001
      Packet Serial Number: 0x00000001
    InfiniBand: RDMA Extended Transport Header (16 bytes)
      Virtual Address: 0x7f8b40000000, Remote Key: 0x5678
      DMA Length: 4096, Reserved: 0x0000
    Data: 4096 bytes of application data

# RDMA Read Request
10:04:56.000002 IP 192.168.1.10.18515 > 192.168.1.20.18515: RoCE v2, length 68
    InfiniBand: Local Route Header (8 bytes)
    InfiniBand: Global Route Header (40 bytes)
    InfiniBand: Base Transport Header (12 bytes)
      Opcode: RDMA Read Request (0x08)
    InfiniBand: RDMA Extended Transport Header (16 bytes)
      Virtual Address: 0x7f8b40001000, Remote Key: 0x9ABC
      DMA Length: 1024, Reserved: 0x0000

# RDMA Read Response
10:04:56.000003 IP 192.168.1.20.18515 > 192.168.1.10.18515: RoCE v2, length 1084
    InfiniBand: Local Route Header (8 bytes)
    InfiniBand: Global Route Header (40 bytes)
    InfiniBand: Base Transport Header (12 bytes)
      Opcode: RDMA Read Response (0x09)
    InfiniBand: RDMA Extended Transport Header (16 bytes)
      Virtual Address: 0x7f8b40001000, Remote Key: 0x9ABC
      DMA Length: 1024, Reserved: 0x0000
    Data: 1024 bytes of read data

# Send Operation (Message Passing)
10:04:56.000004 IP 192.168.1.10.18515 > 192.168.1.20.18515: RoCE v2, length 100
    InfiniBand: Local Route Header (8 bytes)
    InfiniBand: Global Route Header (40 bytes)
    InfiniBand: Base Transport Header (12 bytes)
      Opcode: Send (0x04)
    InfiniBand: Data Extended Transport Header (8 bytes)
      Queue Key: 0x1234, Reserved: 0x0000
    Data: 64 bytes of message data

# Atomic Compare and Swap
10:04:56.000005 IP 192.168.1.10.18515 > 192.168.1.20.18515: RoCE v2, length 68
    InfiniBand: Local Route Header (8 bytes)
    InfiniBand: Global Route Header (40 bytes)
    InfiniBand: Base Transport Header (12 bytes)
      Opcode: Atomic Compare and Swap (0x0F)
    InfiniBand: Atomic Extended Transport Header (16 bytes)
      Virtual Address: 0x7f8b40002000, Remote Key: 0xDEF0
      Compare Add: 0x0000000000000000, Swap: 0x0000000000000001

# Atomic Response
10:04:56.000006 IP 192.168.1.20.18515 > 192.168.1.10.18515: RoCE v2, length 76
    InfiniBand: Local Route Header (8 bytes)
    InfiniBand: Global Route Header (40 bytes)
    InfiniBand: Base Transport Header (12 bytes)
      Opcode: Atomic Response (0x10)
    InfiniBand: Atomic Extended Transport Header (16 bytes)
      Virtual Address: 0x7f8b40002000, Remote Key: 0xDEF0
      Compare Add: 0x0000000000000000, Swap: 0x0000000000000001
    Data: 8 bytes of atomic result

# Queue Pair State Change
10:04:56.000007 IP 192.168.1.10.18515 > 192.168.1.20.18515: RoCE v2, length 68
    InfiniBand: Local Route Header (8 bytes)
    InfiniBand: Global Route Header (40 bytes)
    InfiniBand: Base Transport Header (12 bytes)
      Opcode: Send (0x04)
    InfiniBand: Data Extended Transport Header (8 bytes)
    Data: 16 bytes of QP state change notification

# Memory Registration
10:04:56.000008 IP 192.168.1.10.18515 > 192.168.1.20.18515: RoCE v2, length 100
    InfiniBand: Local Route Header (8 bytes)
    InfiniBand: Global Route Header (40 bytes)
    InfiniBand: Base Transport Header (12 bytes)
      Opcode: Send (0x04)
    InfiniBand: Data Extended Transport Header (8 bytes)
    Data: 64 bytes of memory region information

# Completion Notification
10:04:56.000009 IP 192.168.1.20.18515 > 192.168.1.10.18515: RoCE v2, length 68
    InfiniBand: Local Route Header (8 bytes)
    InfiniBand: Global Route Header (40 bytes)
    InfiniBand: Base Transport Header (12 bytes)
      Opcode: Send (0x04)
    InfiniBand: Data Extended Transport Header (8 bytes)
    Data: 16 bytes of completion notification
EOF

print_success "Simulated RDMA traffic capture created"

print_header "5. RDMA Traffic Analysis"
print_status "Analyzing simulated RDMA traffic patterns..."

echo "Traffic Pattern Analysis:"
echo "  - RDMA Write: High bandwidth, one-way data transfer"
echo "  - RDMA Read: Request/response pattern, remote memory access"
echo "  - Send/Receive: Message passing, RPC operations"
echo "  - Atomic: Synchronization, low latency operations"
echo "  - Control: Queue pair management, memory registration"
echo

print_rdma "Performance Characteristics:"
echo "  - Latency: 1-5 μs (hardware), 2-10 μs (SoftRoCE)"
echo "  - Bandwidth: 10-400 Gbps (depending on hardware)"
echo "  - Packet Rate: 1-10M packets/second"
echo "  - CPU Usage: < 1% (hardware), 10-30% (SoftRoCE)"
echo

print_header "6. RDMA vs Traditional Network Traffic"
print_status "Comparing RDMA traffic with traditional TCP/IP:"

echo "Traditional TCP/IP Traffic:"
echo "  - Protocol: TCP/IP stack"
echo "  - Headers: Ethernet + IP + TCP (54 bytes)"
echo "  - Processing: Kernel-based"
echo "  - Latency: 10-50 μs"
echo "  - Bandwidth: Limited by CPU"
echo "  - Features: Reliable, ordered delivery"
echo

print_rdma "RDMA Traffic:"
echo "  - Protocol: InfiniBand over Ethernet"
echo "  - Headers: Ethernet + IB + BTH + RETH (78 bytes)"
echo "  - Processing: Hardware offload"
echo "  - Latency: 1-10 μs"
echo "  - Bandwidth: Near line rate"
echo "  - Features: Zero-copy, kernel bypass"
echo

print_header "7. RDMA Traffic Monitoring"
print_status "Tools and techniques for monitoring RDMA traffic:"

echo "Packet Capture Tools:"
echo "  - tcpdump: Basic packet capture"
echo "  - wireshark: Protocol analysis"
echo "  - ibdiagnet: InfiniBand diagnostics"
echo "  - ibnetdiscover: Topology discovery"
echo

echo "Performance Monitoring:"
echo "  - ibstat: Device statistics"
echo "  - ibv_devinfo: Device information"
echo "  - perf: CPU performance analysis"
echo "  - htop: Process monitoring"
echo

print_header "8. Real RDMA Traffic Capture Example"
print_status "Showing how to capture real RDMA traffic:"

echo "Capture Commands:"
echo "  # Capture all RDMA traffic"
echo "  sudo tcpdump -i eth0 -w rdma_capture.pcap port 18515"
echo
echo "  # Capture specific RDMA operations"
echo "  sudo tcpdump -i eth0 -w rdma_write.pcap 'port 18515 and tcp[20:4] = 0x08'"
echo
echo "  # Monitor RDMA performance"
echo "  ib_write_bw -d rxe0 -s 4K -n 1000 &"
echo "  sudo tcpdump -i eth0 -w rdma_perf.pcap port 18515"
echo

print_header "9. RDMA Traffic Patterns in Applications"
print_status "Common RDMA traffic patterns in real applications:"

print_rdma "High-Performance Computing (MPI):"
echo "  - Bulk data transfers (RDMA Write)"
echo "  - Collective operations (Send/Receive)"
echo "  - Synchronization (Atomic operations)"
echo "  - Pattern: Burst traffic during computation phases"
echo

print_rdma "Storage Systems (NVMe-oF):"
echo "  - Large block transfers (RDMA Write/Read)"
echo "  - Command processing (Send/Receive)"
echo "  - Status updates (Atomic operations)"
echo "  - Pattern: Sustained high bandwidth"
echo

print_rdma "Machine Learning (Distributed Training):"
echo "  - Gradient updates (RDMA Write)"
echo "  - Parameter synchronization (Atomic operations)"
echo "  - Model broadcasting (Send/Receive)"
echo "  - Pattern: Periodic synchronization bursts"
echo

print_header "10. Troubleshooting RDMA Traffic"
print_status "Common RDMA traffic issues and solutions:"

echo "Connection Issues:"
echo "  - Check queue pair state: ibv_devinfo -d rxe0"
echo "  - Verify memory registration: ibv_reg_mr()"
echo "  - Monitor completion queue: ibv_poll_cq()"
echo

echo "Performance Issues:"
echo "  - Check packet drops: ibstat rxe0"
echo "  - Monitor CPU usage: htop"
echo "  - Analyze network utilization: ethtool -S eth0"
echo

echo "Traffic Analysis:"
echo "  - Filter by operation type: tcpdump 'port 18515 and tcp[20:4] = 0x08'"
echo "  - Monitor specific flows: tcpdump 'host 192.168.1.10 and port 18515'"
echo "  - Analyze timing: tcpdump -tt 'port 18515'"
echo

print_header "Demo Complete"
print_success "RDMA traffic simulation and analysis completed!"

print_status "Files created:"
echo "  - simulated_rdma_traffic.txt: Detailed RDMA packet examples"
echo "  - This demonstration: Complete RDMA traffic analysis"

print_warning "Note: This simulation shows what RDMA traffic looks like."
print_status "For real RDMA traffic capture, you need:"
echo "  - RDMA hardware or SoftRoCE setup"
echo "  - Two machines with RDMA connectivity"
echo "  - Proper network configuration"
echo "  - RDMA applications running"

echo
print_rdma "RDMA traffic provides:"
echo "  ✓ Ultra-low latency (μs range)"
echo "  ✓ High bandwidth (Gbps range)"
echo "  ✓ Zero-copy operations"
echo "  ✓ Kernel bypass"
echo "  ✓ Hardware offload"
echo "  ✓ Reliable delivery"
