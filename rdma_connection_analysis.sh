#!/bin/bash

# RDMA/RoCEv2 Connection Establishment Analysis
# This script explains the complete RDMA connection establishment process

echo "=========================================="
echo "RDMA/RoCEv2 Connection Establishment Analysis"
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

print_header "1. RDMA Connection Establishment Overview"
print_status "RDMA connection establishment is a multi-phase process:"

echo "Phase 1: Device Discovery and Capability Exchange"
echo "  - Client discovers available RDMA devices"
echo "  - Server responds with device capabilities"
echo "  - Both sides exchange supported features"
echo

echo "Phase 2: Queue Pair Creation and Configuration"
echo "  - Client creates Queue Pair (QP)"
echo "  - Server creates corresponding QP"
echo "  - QP parameters are negotiated"
echo

echo "Phase 3: Memory Region Registration"
echo "  - Client registers memory regions"
echo "  - Server registers memory regions"
echo "  - Memory keys are exchanged"
echo

echo "Phase 4: Connection Establishment"
echo "  - Client initiates connection"
echo "  - Server accepts connection"
echo "  - QP state transitions occur"
echo

echo "Phase 5: Data Transfer Operations"
echo "  - Connection is ready for RDMA operations"
echo "  - Data transfer begins"
echo

print_header "2. Queue Pair State Transitions"
print_status "Understanding QP state machine:"

print_rdma "QP States:"
echo "  RESET -> INIT -> RTR -> RTS -> ERROR"
echo "    |      |      |      |       |"
echo "    |      |      |      |       |"
echo "    +------+------+------+-------|"
echo "           |      |      |       |"
echo "           |      |      |       |"
echo "           +------+------+-------|"
echo "                  |      |       |"
echo "                  |      |       |"
echo "                  +------+-------|"
echo "                         |       |"
echo "                         |       |"
echo "                         +-------|"
echo "                                 |"
echo "                                 |"
echo "                                 +"
echo

echo "State Descriptions:"
echo "  RESET: QP is not initialized"
echo "  INIT: QP is created but not configured"
echo "  RTR: Ready to Receive (configured, waiting for connection)"
echo "  RTS: Ready to Send (connected, ready for data transfer)"
echo "  ERROR: Error condition occurred"
echo

print_header "3. Memory Region Registration Process"
print_status "Memory regions must be registered before RDMA operations:"

print_rdma "Memory Registration Steps:"
echo "  1. Allocate memory buffer"
echo "  2. Register memory region with RDMA device"
echo "  3. Get local key (lkey) for local access"
echo "  4. Get remote key (rkey) for remote access"
echo "  5. Exchange keys with remote peer"
echo "  6. Deregister when done"
echo

echo "Memory Region States:"
echo "  UNREGISTERED: Memory not accessible for RDMA"
echo "  REGISTERED: Memory accessible for RDMA operations"
echo "  INVALID: Memory region has been invalidated"
echo

print_header "4. Connection Establishment Flow"
print_status "Detailed connection establishment process:"

echo "Step 1: Device Discovery"
echo "  Client -> Server: Device Discovery Request"
echo "  Server -> Client: Device Discovery Response"
echo "  - Exchange device capabilities"
echo "  - Negotiate supported features"
echo "  - Establish device context"
echo

echo "Step 2: Queue Pair Creation"
echo "  Client: Create QP with desired parameters"
echo "  Server: Create corresponding QP"
echo "  - QP numbers are assigned"
echo "  - Queue sizes are negotiated"
echo "  - Transport type is determined"
echo

echo "Step 3: Memory Region Registration"
echo "  Client: Register memory regions"
echo "  Server: Register memory regions"
echo "  - Memory keys are generated"
echo "  - Access permissions are set"
echo "  - Keys are exchanged"
echo

echo "Step 4: Connection Establishment"
echo "  Client -> Server: Connection Request"
echo "  Server -> Client: Connection Accept"
echo "  Client -> Server: Connection Confirm"
echo "  - QP state transitions to RTS"
echo "  - Connection is ready for data transfer"
echo

print_header "5. RDMA Connection Types"
print_status "Different connection types and their characteristics:"

print_rdma "RC (Reliable Connection):"
echo "  - Guaranteed delivery and ordering"
echo "  - Connection-oriented"
echo "  - Best for: Critical data transfers"
echo "  - State: Full connection establishment required"
echo

print_rdma "UC (Unreliable Connection):"
echo "  - No delivery guarantees, maintains ordering"
echo "  - Connection-oriented"
echo "  - Best for: High-performance streaming"
echo "  - State: Simplified connection establishment"
echo

print_rdma "UD (Unreliable Datagram):"
echo "  - Datagram-based, no connection state"
echo "  - Connectionless"
echo "  - Best for: Multicast, discovery"
echo "  - State: No connection establishment needed"
echo

print_rdma "XRC (eXtended Reliable Connection):"
echo "  - Shared receive queues"
echo "  - Connection-oriented"
echo "  - Best for: Scalable applications"
echo "  - State: Extended connection establishment"
echo

print_header "6. Connection Establishment Traffic Patterns"
print_status "Traffic patterns during connection establishment:"

echo "Discovery Phase:"
echo "  - Small packets (68-100 bytes)"
echo "  - Bidirectional exchange"
echo "  - Low bandwidth, high latency"
echo

echo "Setup Phase:"
echo "  - Medium packets (100-200 bytes)"
echo "  - Configuration exchange"
echo "  - Moderate bandwidth"
echo

echo "Connection Phase:"
echo "  - Small packets (68-100 bytes)"
echo "  - State transition messages"
echo "  - Low bandwidth, low latency"
echo

echo "Data Phase:"
echo "  - Large packets (1KB-2GB)"
echo "  - High bandwidth operations"
echo "  - Low latency, high throughput"
echo

print_header "7. Connection Establishment Commands"
print_status "Commands to monitor connection establishment:"

echo "Monitor QP State:"
echo "  ibv_devinfo -d rxe0"
echo "  ibstat rxe0"
echo

echo "Monitor Memory Regions:"
echo "  cat /sys/class/infiniband/rxe0/ports/1/pkeys"
echo "  cat /sys/class/infiniband/rxe0/ports/1/gids"
echo

echo "Monitor Connections:"
echo "  netstat -ulnp | grep 4791"
echo "  ss -ulnp | grep 4791"
echo

echo "Monitor Traffic:"
echo "  sudo tcpdump -i eth0 port 4791"
echo "  sudo tcpdump -i eth0 'port 4791 and udp[20:4] = 0x04'"
echo

print_header "8. Connection Establishment Troubleshooting"
print_status "Common issues and solutions:"

echo "QP Creation Issues:"
echo "  - Check device availability: ibv_devices"
echo "  - Verify QP parameters: ibv_devinfo -d rxe0"
echo "  - Check memory allocation: free -h"
echo

echo "Memory Registration Issues:"
echo "  - Check memory alignment: alignment requirements"
echo "  - Verify access permissions: read/write flags"
echo "  - Check protection domain: PD configuration"
echo

echo "Connection Issues:"
echo "  - Check network connectivity: ping"
echo "  - Verify port availability: netstat -ulnp | grep 4791"
echo "  - Check firewall rules: iptables -L"
echo

echo "State Transition Issues:"
echo "  - Check QP state: ibv_devinfo -d rxe0"
echo "  - Verify connection parameters: timeout, retry counts"
echo "  - Check for errors: dmesg | grep -i rdma"
echo

print_header "9. Connection Establishment Performance"
print_status "Performance characteristics of connection establishment:"

echo "Latency Breakdown:"
echo "  Device Discovery: 1-5 ms"
echo "  QP Creation: 0.1-1 ms"
echo "  Memory Registration: 0.1-0.5 ms"
echo "  Connection Establishment: 0.1-1 ms"
echo "  Total: 1.3-7.5 ms"
echo

echo "Bandwidth Usage:"
echo "  Discovery Phase: < 1 Kbps"
echo "  Setup Phase: < 10 Kbps"
echo "  Connection Phase: < 1 Kbps"
echo "  Data Phase: 10-100 Gbps"
echo

echo "CPU Usage:"
echo "  Discovery Phase: < 1%"
echo "  Setup Phase: < 5%"
echo "  Connection Phase: < 1%"
echo "  Data Phase: 5-30%"
echo

print_header "10. Connection Establishment Best Practices"
print_status "Best practices for RDMA connection establishment:"

echo "Design Principles:"
echo "  - Minimize connection establishment overhead"
echo "  - Use connection pooling when possible"
echo "  - Implement proper error handling"
echo "  - Monitor connection health"
echo

echo "Performance Optimization:"
echo "  - Pre-allocate memory regions"
echo "  - Use appropriate QP sizes"
echo "  - Implement connection caching"
echo "  - Monitor and tune timeouts"
echo

echo "Error Handling:"
echo "  - Implement retry mechanisms"
echo "  - Handle connection failures gracefully"
echo "  - Monitor connection state"
echo "  - Implement health checks"
echo

echo "Security Considerations:"
echo "  - Validate connection parameters"
echo "  - Implement access control"
echo "  - Monitor for suspicious activity"
echo "  - Use secure key exchange"
echo

print_header "Demo Complete"
print_success "RDMA connection establishment analysis completed!"

print_status "Files created:"
echo "  - rdma_connection_establishment.txt: Detailed connection flow"
echo "  - This demonstration: Complete connection analysis"

print_rdma "Connection establishment provides:"
echo "  ✓ Reliable connection setup"
echo "  ✓ Memory region management"
echo "  ✓ State machine management"
echo "  ✓ Error handling and recovery"
echo "  ✓ Performance optimization"
echo "  ✓ Security and access control"
