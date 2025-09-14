#!/bin/bash

# Comprehensive RDMA Check for C2 Instance
# Run this script on your C2 instance to check RDMA capabilities

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                RDMA Capability Check for C2                 ║"
echo "║                    $(date)                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check and display status
check_status() {
    local test_name="$1"
    local command="$2"
    local success_msg="$3"
    local fail_msg="$4"
    
    echo -n "Checking $test_name... "
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✓ $success_msg${NC}"
        return 0
    else
        echo -e "${RED}✗ $fail_msg${NC}"
        return 1
    fi
}

echo "1. System Information:"
echo "======================"
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime)"
echo ""

echo "2. CPU Information:"
echo "==================="
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core|Socket"
echo ""

echo "3. Memory Information:"
echo "======================"
free -h
echo ""

echo "4. RDMA Hardware Check:"
echo "======================="
check_status "InfiniBand devices" "ls /sys/class/infiniband/" "Found" "Not found"
check_status "RDMA devices" "ls /sys/class/infiniband/*/device" "Found" "Not found"

if [ -d "/sys/class/infiniband" ]; then
    echo "InfiniBand devices found:"
    for device in /sys/class/infiniband/*; do
        if [ -d "$device" ]; then
            device_name=$(basename $device)
            echo "  - $device_name"
            
            # Check ports
            for port in $device/ports/*; do
                if [ -d "$port" ]; then
                    port_num=$(basename $port)
                    state=$(cat $port/state 2>/dev/null || echo "unknown")
                    echo "    Port $port_num: $state"
                fi
            done
        fi
    done
else
    echo "No InfiniBand devices found"
fi
echo ""

echo "5. RDMA Software Check:"
echo "======================="
check_status "RDMA modules" "lsmod | grep -i rdma" "Loaded" "Not loaded"
check_status "ibv_devices tool" "which ibv_devices" "Available" "Not available"
check_status "ibv_devinfo tool" "which ibv_devinfo" "Available" "Not available"

if command -v ibv_devices &>/dev/null; then
    echo "RDMA devices (ibv_devices):"
    ibv_devices 2>/dev/null || echo "No devices found"
fi
echo ""

echo "6. Network Interfaces:"
echo "======================"
echo "All interfaces:"
ip link show | grep -E "^[0-9]+:" | while read line; do
    echo "  $line"
done
echo ""

echo "Interface details:"
ip addr show | grep -E "inet |UP|DOWN"
echo ""

echo "7. RDMA Libraries Check:"
echo "========================"
check_status "libibverbs" "ldconfig -p | grep libibverbs" "Installed" "Not installed"
check_status "librdmacm" "ldconfig -p | grep librdmacm" "Installed" "Not installed"
check_status "pkg-config libibverbs" "pkg-config --exists libibverbs" "Available" "Not available"
check_status "pkg-config librdmacm" "pkg-config --exists librdmacm" "Available" "Not available"
echo ""

echo "8. RDMA Tools Check:"
echo "===================="
tools=("ibv_devices" "ibv_devinfo" "ibv_rc_ping_test" "rdma" "ibstat" "ibdiagnet")
for tool in "${tools[@]}"; do
    check_status "$tool" "which $tool" "Available" "Not available"
done
echo ""

echo "9. Kernel Modules:"
echo "=================="
echo "RDMA-related modules:"
lsmod | grep -i -E "rdma|ib|infiniband" || echo "No RDMA modules loaded"
echo ""

echo "10. System Logs (RDMA-related):"
echo "==============================="
echo "Recent RDMA messages from dmesg:"
dmesg | grep -i -E "rdma|ib|infiniband" | tail -10 || echo "No RDMA messages in dmesg"
echo ""

echo "11. C2 Instance Specific Checks:"
echo "================================"
echo "Instance type check:"
if [ -f "/proc/cpuinfo" ]; then
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    echo "CPU Model: $cpu_model"
    
    # Check for Intel Xeon (common in C2 instances)
    if echo "$cpu_model" | grep -i "xeon" &>/dev/null; then
        echo -e "${GREEN}✓ Intel Xeon CPU detected (good for RDMA)${NC}"
    else
        echo -e "${YELLOW}⚠ Non-Xeon CPU detected${NC}"
    fi
fi

echo "NUMA topology:"
if command -v numactl &>/dev/null; then
    numactl --hardware 2>/dev/null || echo "numactl not available"
else
    echo "numactl not installed"
fi
echo ""

echo "12. RDMA Performance Test (if available):"
echo "=========================================="
if command -v ibv_rc_ping_test &>/dev/null; then
    echo "Running basic RDMA ping test..."
    timeout 10 ibv_rc_ping_test 2>/dev/null || echo "RDMA ping test failed or no devices"
else
    echo "ibv_rc_ping_test not available"
fi
echo ""

echo "13. Summary:"
echo "============"
rdma_hardware=$(ls /sys/class/infiniband/ 2>/dev/null | wc -l)
rdma_software=$(lsmod | grep -i rdma | wc -l)
rdma_tools=$(which ibv_devices ibv_devinfo 2>/dev/null | wc -l)

echo "RDMA Hardware devices: $rdma_hardware"
echo "RDMA Kernel modules: $rdma_software"
echo "RDMA Tools available: $rdma_tools"

if [ $rdma_hardware -gt 0 ] && [ $rdma_software -gt 0 ]; then
    echo -e "${GREEN}🎉 RDMA appears to be available and working!${NC}"
    echo "You can run the RDMA application on this instance."
elif [ $rdma_hardware -eq 0 ] && [ $rdma_software -gt 0 ]; then
    echo -e "${YELLOW}⚠ RDMA software is available but no hardware detected${NC}"
    echo "This might be a software-only environment."
elif [ $rdma_hardware -gt 0 ] && [ $rdma_software -eq 0 ]; then
    echo -e "${YELLOW}⚠ RDMA hardware detected but software not loaded${NC}"
    echo "Try: sudo modprobe ib_core ib_uverbs rdma_cm"
else
    echo -e "${RED}❌ No RDMA capabilities detected${NC}"
    echo "This instance may not support RDMA or needs configuration."
fi

echo ""
echo "Next steps:"
echo "1. If RDMA is available, upload and run the RDMA application"
echo "2. If not available, check instance type and enable RDMA"
echo "3. For GCP C2 instances, ensure Enhanced Networking is enabled"
echo ""
echo "Check completed at: $(date)"
