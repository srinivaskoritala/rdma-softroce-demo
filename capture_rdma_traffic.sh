#!/bin/bash

# RDMA RoCEv2 Traffic Capture Script
# This script captures RoCEv2 packets and analyzes throughput

set -e

# Configuration
INTERFACE="eth0"  # Change this to your network interface
CAPTURE_FILE="rdma_capture.pcap"
ANALYSIS_FILE="rdma_analysis.txt"
DURATION=60  # Capture duration in seconds
PORT=18515   # RDMA port

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}RDMA RoCEv2 Traffic Capture and Analysis Tool${NC}"
echo "=================================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Check if tcpdump is available
if ! command -v tcpdump &> /dev/null; then
    echo -e "${RED}tcpdump is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if tshark is available for analysis
if ! command -v tshark &> /dev/null; then
    echo -e "${YELLOW}tshark is not available. Basic capture will be performed.${NC}"
    ANALYSIS_AVAILABLE=false
else
    ANALYSIS_AVAILABLE=true
fi

# Function to find the correct network interface
find_interface() {
    echo -e "${YELLOW}Detecting network interfaces...${NC}"
    
    # List available interfaces
    interfaces=$(ip link show | grep -E "^[0-9]+:" | cut -d: -f2 | tr -d ' ')
    
    echo "Available interfaces:"
    for iface in $interfaces; do
        if [ "$iface" != "lo" ]; then
            echo "  - $iface"
        fi
    done
    
    # Try to find an interface with an IP address
    for iface in $interfaces; do
        if [ "$iface" != "lo" ] && ip addr show "$iface" | grep -q "inet "; then
            INTERFACE="$iface"
            echo -e "${GREEN}Using interface: $INTERFACE${NC}"
            break
        fi
    done
}

# Function to start packet capture
start_capture() {
    echo -e "${YELLOW}Starting packet capture on interface $INTERFACE...${NC}"
    echo "Capture duration: $DURATION seconds"
    echo "Output file: $CAPTURE_FILE"
    
    # Capture RoCEv2 traffic (UDP port 4791 is the standard RoCEv2 port)
    # Also capture our custom port for RDMA CM traffic
    tcpdump -i "$INTERFACE" -w "$CAPTURE_FILE" \
        "(udp port 4791 or udp port $PORT) and (host $(hostname -I | awk '{print $1}'))" &
    
    CAPTURE_PID=$!
    echo "Capture PID: $CAPTURE_PID"
    
    # Wait for the specified duration
    echo -e "${YELLOW}Capturing for $DURATION seconds...${NC}"
    sleep $DURATION
    
    # Stop capture
    echo -e "${YELLOW}Stopping capture...${NC}"
    kill $CAPTURE_PID 2>/dev/null || true
    wait $CAPTURE_PID 2>/dev/null || true
    
    echo -e "${GREEN}Capture completed. File saved as: $CAPTURE_FILE${NC}"
}

# Function to analyze captured packets
analyze_capture() {
    if [ "$ANALYSIS_AVAILABLE" = false ]; then
        echo -e "${YELLOW}Skipping analysis (tshark not available)${NC}"
        return
    fi
    
    echo -e "${YELLOW}Analyzing captured packets...${NC}"
    
    # Create analysis file
    cat > "$ANALYSIS_FILE" << EOF
RDMA RoCEv2 Traffic Analysis
============================
Capture file: $CAPTURE_FILE
Interface: $INTERFACE
Duration: $DURATION seconds
Timestamp: $(date)

EOF

    # Basic packet statistics
    echo "=== Packet Statistics ===" >> "$ANALYSIS_FILE"
    tshark -r "$CAPTURE_FILE" -q -z conv,udp >> "$ANALYSIS_FILE" 2>/dev/null || echo "No UDP conversations found" >> "$ANALYSIS_FILE"
    
    echo "" >> "$ANALYSIS_FILE"
    echo "=== RoCEv2 Packet Analysis ===" >> "$ANALYSIS_FILE"
    
    # Analyze RoCEv2 packets (UDP port 4791)
    rocev2_packets=$(tshark -r "$CAPTURE_FILE" -Y "udp.port == 4791" -T fields -e frame.number | wc -l)
    echo "RoCEv2 packets (port 4791): $rocev2_packets" >> "$ANALYSIS_FILE"
    
    # Analyze RDMA CM packets (our custom port)
    rdma_cm_packets=$(tshark -r "$CAPTURE_FILE" -Y "udp.port == $PORT" -T fields -e frame.number | wc -l)
    echo "RDMA CM packets (port $PORT): $rdma_cm_packets" >> "$ANALYSIS_FILE"
    
    # Calculate throughput
    if [ "$rocev2_packets" -gt 0 ]; then
        # Get total bytes for RoCEv2 traffic
        total_bytes=$(tshark -r "$CAPTURE_FILE" -Y "udp.port == 4791" -T fields -e frame.len | awk '{sum += $1} END {print sum}')
        if [ -n "$total_bytes" ] && [ "$total_bytes" -gt 0 ]; then
            throughput_mbps=$(echo "scale=2; $total_bytes * 8 / $DURATION / 1000000" | bc -l 2>/dev/null || echo "N/A")
            throughput_mb_s=$(echo "scale=2; $total_bytes / $DURATION / 1000000" | bc -l 2>/dev/null || echo "N/A")
            echo "Total RoCEv2 bytes: $total_bytes" >> "$ANALYSIS_FILE"
            echo "Throughput: $throughput_mbps Mbps" >> "$ANALYSIS_FILE"
            echo "Throughput: $throughput_mb_s MB/s" >> "$ANALYSIS_FILE"
        fi
    fi
    
    echo "" >> "$ANALYSIS_FILE"
    echo "=== Detailed Packet Information ===" >> "$ANALYSIS_FILE"
    tshark -r "$CAPTURE_FILE" -Y "udp.port == 4791 or udp.port == $PORT" -T fields \
        -e frame.time -e ip.src -e ip.dst -e udp.srcport -e udp.dstport -e frame.len >> "$ANALYSIS_FILE" 2>/dev/null || echo "No matching packets found" >> "$ANALYSIS_FILE"
    
    echo -e "${GREEN}Analysis completed. Results saved to: $ANALYSIS_FILE${NC}"
}

# Function to display real-time statistics
show_realtime_stats() {
    echo -e "${YELLOW}Real-time network statistics:${NC}"
    echo "Press Ctrl+C to stop monitoring"
    
    # Monitor network interface statistics
    while true; do
        clear
        echo -e "${BLUE}RDMA Traffic Monitor - $(date)${NC}"
        echo "=================================="
        
        # Show interface statistics
        if [ -f "/sys/class/net/$INTERFACE/statistics/rx_bytes" ]; then
            rx_bytes=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
            tx_bytes=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
            rx_packets=$(cat /sys/class/net/$INTERFACE/statistics/rx_packets)
            tx_packets=$(cat /sys/class/net/$INTERFACE/statistics/tx_packets)
            
            echo "Interface: $INTERFACE"
            echo "RX Bytes: $rx_bytes"
            echo "TX Bytes: $tx_bytes"
            echo "RX Packets: $rx_packets"
            echo "TX Packets: $tx_packets"
        fi
        
        # Show UDP port statistics
        if command -v ss &> /dev/null; then
            echo ""
            echo "UDP Port Statistics:"
            ss -ulnp | grep -E ":$PORT|:4791"
        fi
        
        sleep 2
    done
}

# Main execution
case "${1:-capture}" in
    "capture")
        find_interface
        start_capture
        analyze_capture
        ;;
    "monitor")
        find_interface
        show_realtime_stats
        ;;
    "analyze")
        if [ -f "$CAPTURE_FILE" ]; then
            analyze_capture
        else
            echo -e "${RED}Capture file $CAPTURE_FILE not found${NC}"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {capture|monitor|analyze}"
        echo "  capture  - Capture packets for $DURATION seconds and analyze"
        echo "  monitor  - Show real-time network statistics"
        echo "  analyze  - Analyze existing capture file"
        exit 1
        ;;
esac

echo -e "${GREEN}Script completed successfully${NC}"
