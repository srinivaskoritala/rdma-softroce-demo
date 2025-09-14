#!/bin/bash

# RDMA RoCEv2 Demo Script
# This script demonstrates the RDMA application with step-by-step execution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                RDMA RoCEv2 Application Demo                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print step headers
print_step() {
    echo -e "${CYAN}Step $1: $2${NC}"
    echo "----------------------------------------"
}

# Function to wait for user input
wait_for_user() {
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Note: Some features require root privileges for packet capture${NC}"
    echo "For full functionality, run: sudo $0"
    echo ""
fi

# Step 1: Check requirements
print_step "1" "Checking System Requirements"
echo "Checking for RDMA devices and required libraries..."

if make check-requirements; then
    echo -e "${GREEN}✓ All requirements satisfied${NC}"
else
    echo -e "${RED}✗ Requirements not met${NC}"
    echo "Please install dependencies first:"
    echo "  make install-deps"
    exit 1
fi

wait_for_user

# Step 2: Build application
print_step "2" "Building RDMA Application"
echo "Compiling server and client..."

if make clean all; then
    echo -e "${GREEN}✓ Build successful${NC}"
    echo "Created executables:"
    echo "  - rdma_server"
    echo "  - rdma_client"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

wait_for_user

# Step 3: Show application architecture
print_step "3" "Application Architecture"
echo "The RDMA application consists of:"
echo ""
echo "┌─────────────────┐    RDMA RoCEv2     ┌─────────────────┐"
echo "│   RDMA Client   │◄──────────────────►│   RDMA Server   │"
echo "│                 │    (Port 18515)    │                 │"
echo "└─────────────────┘                    └─────────────────┘"
echo "         │                                       │"
echo "         ▼                                       ▼"
echo "┌─────────────────┐                    ┌─────────────────┐"
echo "│ Packet Capture  │                    │ Throughput      │"
echo "│ (tcpdump)       │                    │ Monitor         │"
echo "└─────────────────┘                    └─────────────────┘"
echo ""
echo "Features:"
echo "  • RDMA Write operations with 1MB buffers"
echo "  • Real-time packet capture and analysis"
echo "  • Throughput monitoring and statistics"
echo "  • Performance measurement and reporting"

wait_for_user

# Step 4: Start monitoring tools
print_step "4" "Starting Monitoring Tools"

# Create results directory
mkdir -p demo_results
cd demo_results

echo "Starting throughput monitoring..."
python3 ../throughput_monitor.py -d 30 -o demo_throughput.json &
MONITOR_PID=$!
sleep 2

if [ "$EUID" -eq 0 ]; then
    echo "Starting packet capture..."
    ../capture_rdma_traffic.sh capture &
    CAPTURE_PID=$!
    sleep 2
    echo -e "${GREEN}✓ Monitoring tools started${NC}"
else
    echo -e "${YELLOW}⚠ Skipping packet capture (requires root)${NC}"
    echo -e "${GREEN}✓ Throughput monitoring started${NC}"
fi

wait_for_user

# Step 5: Run RDMA application
print_step "5" "Running RDMA Application"
echo "Starting RDMA server in background..."

../rdma_server &
SERVER_PID=$!
sleep 2

echo "Starting RDMA client..."
echo "This will perform 1000 RDMA write operations with 1MB buffers"
echo ""

# Run client and capture output
../rdma_client 2>&1 | tee client_output.log
CLIENT_EXIT_CODE=${PIPESTATUS[0]}

echo ""
if [ $CLIENT_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ RDMA client completed successfully${NC}"
else
    echo -e "${RED}✗ RDMA client failed with exit code $CLIENT_EXIT_CODE${NC}"
fi

# Stop server
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true
echo -e "${GREEN}✓ RDMA server stopped${NC}"

wait_for_user

# Step 6: Analyze results
print_step "6" "Analyzing Results"

echo "Waiting for monitoring to complete..."
wait $MONITOR_PID 2>/dev/null || true

if [ "$EUID" -eq 0 ] && [ -n "$CAPTURE_PID" ]; then
    kill $CAPTURE_PID 2>/dev/null || true
    wait $CAPTURE_PID 2>/dev/null || true
fi

echo ""
echo -e "${BLUE}Throughput Analysis:${NC}"
if [ -f "demo_throughput.json" ]; then
    python3 ../throughput_monitor.py --analyze demo_throughput.json
else
    echo "No throughput data available"
fi

echo ""
echo -e "${BLUE}Packet Capture Analysis:${NC}"
if [ -f "rdma_analysis.txt" ]; then
    cat rdma_analysis.txt
elif [ -f "rdma_capture.pcap" ]; then
    echo "Packet capture file created: rdma_capture.pcap"
    echo "Use Wireshark or tcpdump to analyze:"
    echo "  tcpdump -r rdma_capture.pcap"
    echo "  wireshark rdma_capture.pcap"
else
    echo "No packet capture data available"
fi

echo ""
echo -e "${BLUE}Client Output:${NC}"
if [ -f "client_output.log" ]; then
    cat client_output.log
fi

wait_for_user

# Step 7: Summary
print_step "7" "Demo Summary"
echo -e "${GREEN}Demo completed successfully!${NC}"
echo ""
echo "Generated files in demo_results/:"
ls -la demo_results/

echo ""
echo "Key features demonstrated:"
echo "  ✓ RDMA RoCEv2 client-server communication"
echo "  ✓ High-performance data transfer (1MB buffers)"
echo "  ✓ Real-time throughput monitoring"
if [ "$EUID" -eq 0 ]; then
    echo "  ✓ Packet capture and analysis"
fi
echo "  ✓ Performance measurement and reporting"

echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  • Run 'make test-full' for comprehensive testing"
echo "  • Modify buffer sizes and operation counts in source code"
echo "  • Analyze captured packets with Wireshark"
echo "  • Experiment with different RDMA operations (READ, ATOMIC)"

echo ""
echo -e "${BLUE}Thank you for trying the RDMA RoCEv2 application!${NC}"
