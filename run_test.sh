#!/bin/bash

# RDMA RoCEv2 Test Runner Script
# This script runs the complete RDMA test with packet capture and throughput monitoring

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}RDMA RoCEv2 Complete Test Suite${NC}"
echo "====================================="

# Check if running as root for packet capture
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Note: Running without root privileges. Packet capture will be limited.${NC}"
    echo "For full packet capture, run: sudo $0"
fi

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    pkill -f rdma_server 2>/dev/null || true
    pkill -f rdma_client 2>/dev/null || true
    pkill -f capture_rdma_traffic 2>/dev/null || true
    pkill -f throughput_monitor 2>/dev/null || true
    echo -e "${GREEN}Cleanup completed${NC}"
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Check requirements
echo -e "${YELLOW}Checking system requirements...${NC}"
if ! make check-requirements > /dev/null 2>&1; then
    echo -e "${RED}System requirements not met. Please install dependencies first.${NC}"
    echo "Run: make install-deps"
    exit 1
fi

# Build the application
echo -e "${YELLOW}Building RDMA application...${NC}"
if ! make clean all; then
    echo -e "${RED}Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}Build completed successfully${NC}"

# Create results directory
mkdir -p results
cd results

# Start packet capture (if running as root)
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}Starting packet capture...${NC}"
    ../capture_rdma_traffic.sh capture &
    CAPTURE_PID=$!
    sleep 2
else
    echo -e "${YELLOW}Skipping packet capture (requires root privileges)${NC}"
fi

# Start throughput monitoring
echo -e "${YELLOW}Starting throughput monitoring...${NC}"
python3 ../throughput_monitor.py -d 60 -o throughput_results.json &
MONITOR_PID=$!
sleep 2

# Start RDMA server
echo -e "${YELLOW}Starting RDMA server...${NC}"
../rdma_server &
SERVER_PID=$!
sleep 2

# Start RDMA client
echo -e "${YELLOW}Starting RDMA client...${NC}"
../rdma_client &
CLIENT_PID=$!

# Wait for client to complete
wait $CLIENT_PID
echo -e "${GREEN}RDMA client completed${NC}"

# Wait a bit for server to finish
sleep 2

# Stop server
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true
echo -e "${GREEN}RDMA server stopped${NC}"

# Wait for monitoring to complete
wait $MONITOR_PID
echo -e "${GREEN}Throughput monitoring completed${NC}"

# Stop packet capture if running
if [ "$EUID" -eq 0 ] && [ -n "$CAPTURE_PID" ]; then
    kill $CAPTURE_PID 2>/dev/null || true
    wait $CAPTURE_PID 2>/dev/null || true
    echo -e "${GREEN}Packet capture completed${NC}"
fi

# Analyze results
echo -e "${YELLOW}Analyzing results...${NC}"

if [ -f "throughput_results.json" ]; then
    echo -e "${BLUE}Throughput Analysis:${NC}"
    python3 ../throughput_monitor.py --analyze throughput_results.json
fi

if [ -f "rdma_capture.pcap" ]; then
    echo -e "${BLUE}Packet Capture Analysis:${NC}"
    if [ -f "rdma_analysis.txt" ]; then
        cat rdma_analysis.txt
    else
        echo "Basic packet capture completed. Use tcpdump or Wireshark to analyze rdma_capture.pcap"
    fi
fi

# Generate summary report
echo -e "${BLUE}Test Summary Report${NC}"
echo "===================="
echo "Test completed at: $(date)"
echo "Results directory: $(pwd)"

if [ -f "throughput_results.json" ]; then
    echo "✓ Throughput monitoring data: throughput_results.json"
fi

if [ -f "rdma_capture.pcap" ]; then
    echo "✓ Packet capture data: rdma_capture.pcap"
fi

if [ -f "rdma_analysis.txt" ]; then
    echo "✓ Packet analysis report: rdma_analysis.txt"
fi

echo ""
echo -e "${GREEN}Test suite completed successfully!${NC}"
echo "Check the results directory for detailed analysis."
