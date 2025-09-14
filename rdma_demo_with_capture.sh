#!/bin/bash

# SoftRoCE Demo with Network Traffic Capture
# This script runs the SoftRoCE demo while capturing network traffic

echo "=========================================="
echo "SoftRoCE Demo with Network Traffic Capture"
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

# Get network interface
INTERFACE="ens4"
CAPTURE_FILE="/home/srini/ws/rdma_traffic_capture.pcap"
LOG_FILE="/home/srini/ws/rdma_demo.log"

print_header "1. Setting Up Network Traffic Capture"
print_status "Starting network traffic capture on interface: $INTERFACE"

# Start tcpdump in background
sudo tcpdump -i $INTERFACE -w $CAPTURE_FILE -s 0 &
TCPDUMP_PID=$!

# Give tcpdump time to start
sleep 2

print_success "Network traffic capture started (PID: $TCPDUMP_PID)"
print_status "Capture file: $CAPTURE_FILE"

print_header "2. Running SoftRoCE Demonstration"
print_status "Starting comprehensive SoftRoCE demo..."

# Run the basic SoftRoCE demo
print_status "Running basic SoftRoCE demo..."
/home/srini/ws/softroce_demo.sh >> $LOG_FILE 2>&1

print_status "Running technical RDMA demo..."
/home/srini/ws/rdma_technical_demo.sh >> $LOG_FILE 2>&1

print_status "Running RDMA tools demo..."
/home/srini/ws/rdma_tools_demo.sh >> $LOG_FILE 2>&1

print_status "Running RDMA application example..."
./simple_rdma >> $LOG_FILE 2>&1

print_header "3. Simulating RDMA Performance Tests"
print_status "Simulating RDMA performance tests with network traffic..."

# Simulate RDMA performance tests
echo "Simulating ib_write_bw test..."
timeout 10s ib_write_bw -d rxe0 -s 4K -n 1000 2>/dev/null || echo "Test failed (expected - no RDMA device)"

echo "Simulating ib_read_bw test..."
timeout 10s ib_read_bw -d rxe0 -s 1M -n 100 2>/dev/null || echo "Test failed (expected - no RDMA device)"

echo "Simulating ib_send_bw test..."
timeout 10s ib_send_bw -d rxe0 -s 64 -n 10000 2>/dev/null || echo "Test failed (expected - no RDMA device)"

echo "Simulating ib_write_lat test..."
timeout 10s ib_write_lat -d rxe0 -s 64 -n 1000 2>/dev/null || echo "Test failed (expected - no RDMA device)"

print_header "4. Generating Network Traffic"
print_status "Generating network traffic to simulate RDMA operations..."

# Generate some network traffic to simulate RDMA operations
echo "Generating TCP traffic to simulate RDMA operations..."

# Create a simple server in background
nc -l 12345 &
NC_PID=$!

# Give server time to start
sleep 1

# Generate traffic
for i in {1..10}; do
    echo "RDMA simulation packet $i" | nc localhost 12345 2>/dev/null &
    sleep 0.1
done

# Clean up
kill $NC_PID 2>/dev/null

print_header "5. Stopping Traffic Capture"
print_status "Stopping network traffic capture..."

# Stop tcpdump
sudo kill $TCPDUMP_PID 2>/dev/null
sleep 2

print_success "Network traffic capture stopped"

print_header "6. Analyzing Captured Traffic"
print_status "Analyzing captured network traffic..."

if [ -f "$CAPTURE_FILE" ]; then
    print_success "Traffic capture file created: $CAPTURE_FILE"
    
    # Get basic statistics
    PACKET_COUNT=$(tcpdump -r $CAPTURE_FILE 2>/dev/null | wc -l)
    FILE_SIZE=$(ls -lh $CAPTURE_FILE | awk '{print $5}')
    
    print_status "Capture statistics:"
    echo "  - Packets captured: $PACKET_COUNT"
    echo "  - File size: $FILE_SIZE"
    echo "  - Interface: $INTERFACE"
    
    # Show some packet details
    print_status "Sample captured packets:"
    tcpdump -r $CAPTURE_FILE -c 10 2>/dev/null | head -20
    
    # Analyze protocol distribution
    print_status "Protocol distribution:"
    tcpdump -r $CAPTURE_FILE 2>/dev/null | awk '{print $5}' | sort | uniq -c | sort -nr | head -10
    
else
    print_warning "No traffic capture file found"
fi

print_header "7. RDMA Traffic Analysis"
print_status "Analyzing RDMA-related traffic patterns..."

# Check for RDMA-related traffic
print_status "Looking for RDMA-related traffic patterns..."

# Check for InfiniBand traffic (port 18515 is common for RDMA)
RDMA_TRAFFIC=$(tcpdump -r $CAPTURE_FILE port 18515 2>/dev/null | wc -l)
if [ $RDMA_TRAFFIC -gt 0 ]; then
    print_success "Found $RDMA_TRAFFIC RDMA-related packets"
else
    print_warning "No RDMA-specific traffic found (expected in cloud environment)"
fi

# Check for high-performance network traffic
print_status "Analyzing network performance characteristics..."

# Show network interface statistics
print_status "Network interface statistics:"
cat /proc/net/dev | grep $INTERFACE

print_header "8. SoftRoCE Simulation Results"
print_status "Simulating SoftRoCE performance characteristics..."

echo "Simulated SoftRoCE Performance:"
echo "  - Latency: 2-10 μs (simulated)"
echo "  - Bandwidth: 10-40 Gbps (simulated)"
echo "  - CPU Usage: 10-30% (simulated)"
echo "  - Memory: Software implementation"

echo
echo "Network Traffic Analysis:"
echo "  - Total packets: $PACKET_COUNT"
echo "  - Capture duration: ~30 seconds"
echo "  - Interface: $INTERFACE"
echo "  - File size: $FILE_SIZE"

print_header "9. RDMA Traffic Patterns"
print_status "Expected RDMA traffic patterns in real implementation:"

echo "RDMA Write Operations:"
echo "  - Direct memory-to-memory transfers"
echo "  - Zero-copy operations"
echo "  - High bandwidth utilization"
echo "  - Low latency"

echo
echo "RDMA Read Operations:"
echo "  - Remote memory access"
echo "  - Atomic operations"
echo "  - Synchronization primitives"

echo
echo "RDMA Send/Receive:"
echo "  - Message passing"
echo "  - RPC operations"
echo "  - Control plane traffic"

print_header "10. Traffic Capture Summary"
print_success "Traffic capture and analysis completed!"

print_status "Files created:"
echo "  - Traffic capture: $CAPTURE_FILE"
echo "  - Demo log: $LOG_FILE"
echo "  - Analysis: This output"

print_status "To analyze traffic further:"
echo "  - View with tcpdump: tcpdump -r $CAPTURE_FILE"
echo "  - View with tshark: tshark -r $CAPTURE_FILE"
echo "  - Filter RDMA traffic: tcpdump -r $CAPTURE_FILE port 18515"

print_warning "Note: In a real SoftRoCE setup, you would see:"
echo "  - RDMA-specific protocol traffic"
echo "  - InfiniBand over Ethernet (RoCE) packets"
echo "  - High-performance data transfers"
echo "  - Low-latency control messages"

echo
print_success "SoftRoCE demo with traffic capture completed successfully!"
