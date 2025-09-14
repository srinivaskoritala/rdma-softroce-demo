#!/bin/bash

echo "=== RDMA Capability Check ==="
echo "Instance: $(hostname)"
echo "Date: $(date)"
echo ""

echo "1. System Information:"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo ""

echo "2. RDMA Hardware Check:"
echo "InfiniBand devices:"
ls -la /sys/class/infiniband/ 2>/dev/null || echo "No InfiniBand devices found"
echo ""

echo "3. RDMA Software Check:"
echo "RDMA modules loaded:"
lsmod | grep -i rdma || echo "No RDMA modules loaded"
echo ""

echo "4. Network Interfaces:"
ip link show | grep -E "eth|en|ib"
echo ""

echo "5. RDMA Libraries:"
if command -v ibv_devices &> /dev/null; then
    echo "ibv_devices available:"
    ibv_devices 2>/dev/null || echo "No RDMA devices found"
else
    echo "ibv_devices not available"
fi
echo ""

echo "6. RDMA Tools:"
which ibv_devinfo ibv_rc_ping_test rdma 2>/dev/null || echo "RDMA tools not installed"
echo ""

echo "7. CPU Information:"
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
echo ""

echo "8. Memory Information:"
free -h
echo ""

echo "9. Network Configuration:"
ip addr show
echo ""

echo "10. RDMA Status:"
if [ -d "/sys/class/infiniband" ]; then
    echo "RDMA subsystem present"
    for device in /sys/class/infiniband/*; do
        if [ -d "$device" ]; then
            echo "Device: $(basename $device)"
            cat $device/ports/*/state 2>/dev/null || echo "No port state info"
        fi
    done
else
    echo "RDMA subsystem not available"
fi
