# SoftRoCE (Software RDMA) Demonstration

A comprehensive demonstration of SoftRoCE (Software RDMA over Converged Ethernet) capabilities, including traffic analysis, performance testing, and application development examples.

## Overview

This repository contains a complete SoftRoCE demonstration that showcases:
- RDMA software stack analysis
- Performance testing tools and methodologies
- Traffic capture and analysis techniques
- Application development examples
- Real-world use cases and troubleshooting

## Repository Structure

```
├── README.md                           # This file
├── softroce_demo.sh                    # Basic SoftRoCE demonstration
├── rdma_technical_demo.sh              # Advanced technical analysis
├── rdma_tools_demo.sh                  # Comprehensive tools demonstration
├── rdma_demo_with_capture.sh           # Demo with network traffic capture
├── rdma_traffic_simulation.sh          # RDMA traffic simulation
├── simple_rdma_example.c               # C application example
├── simple_rdma                         # Compiled RDMA application
├── simulated_rdma_traffic.txt          # Simulated RDMA packet examples
├── rdma_traffic_visualization.txt      # Visual traffic patterns
├── rdma_traffic_analysis.md            # Detailed traffic analysis
├── SoftRoCE_Demo_Summary.md            # Complete demonstration summary
└── rdma_traffic_capture.pcap           # Captured network traffic
```

## Features

### 🔧 RDMA Software Stack
- Complete RDMA library analysis (libibverbs, librdmacm)
- Performance testing tools (ib_write_bw, ib_read_bw, etc.)
- Diagnostic tools and monitoring capabilities

### 📊 Traffic Analysis
- Network traffic capture and analysis
- RDMA packet structure visualization
- Performance characteristics comparison
- Real-world traffic patterns

### 💻 Application Development
- C application example with RDMA verbs
- Memory management and queue pair operations
- Work request posting and completion handling
- Error handling and cleanup

### 🚀 Performance Testing
- Bandwidth and latency testing
- Message rate analysis
- Atomic operations demonstration
- Multi-threaded performance testing

## Quick Start

### Prerequisites
- Linux system with RDMA support (for real implementation)
- RDMA libraries: `libibverbs`, `librdmacm`
- Performance tools: `perftest`, `infiniband-diags`
- Network capture tools: `tcpdump`, `wireshark`

### Installation
```bash
# Install RDMA software stack
sudo apt update
sudo apt install -y rdma-core infiniband-diags perftest

# Install network analysis tools
sudo apt install -y tcpdump wireshark
```

### Running the Demos
```bash
# Make scripts executable
chmod +x *.sh

# Run basic SoftRoCE demo
./softroce_demo.sh

# Run technical analysis
./rdma_technical_demo.sh

# Run tools demonstration
./rdma_tools_demo.sh

# Run with traffic capture
./rdma_demo_with_capture.sh

# Run traffic simulation
./rdma_traffic_simulation.sh
```

### Compiling the C Example
```bash
# Compile the RDMA application
gcc -o simple_rdma simple_rdma_example.c -libverbs

# Run the application
./simple_rdma
```

## RDMA Operations

### Supported Operations
- **RDMA Write**: Direct memory-to-memory transfer
- **RDMA Read**: Remote memory access
- **Send/Receive**: Message passing and RPC
- **Atomic**: Synchronization operations

### Transport Types
- **RC (Reliable Connection)**: Guaranteed delivery and ordering
- **UC (Unreliable Connection)**: No delivery guarantees, maintains ordering
- **UD (Unreliable Datagram)**: Datagram-based, no connection state
- **XRC (eXtended Reliable Connection)**: Shared receive queues

## Performance Characteristics

### SoftRoCE vs Hardware RDMA vs TCP/IP

| Technology | Latency | Bandwidth | CPU Usage | Hardware Required |
|------------|---------|-----------|-----------|-------------------|
| Hardware RDMA | 0.5-1.0 μs | 200-400 Gbps | < 1% | Yes |
| SoftRoCE | 2-10 μs | 10-40 Gbps | 10-30% | No |
| TCP/IP | 10-50 μs | 1-10 Gbps | 50-80% | No |

## Use Cases

### High-Performance Computing
- MPI implementations (OpenMPI, MPICH)
- Parallel file systems (Lustre, GPFS)
- Scientific computing frameworks

### Storage Systems
- NVMe over Fabrics (NVMe-oF)
- Distributed storage systems
- Database clustering

### Machine Learning
- Distributed training
- Parameter server architectures
- Gradient synchronization

### Cloud Computing
- Container networking
- Microservices communication
- Serverless computing

## Traffic Analysis

### Captured Traffic
The repository includes captured network traffic (`rdma_traffic_capture.pcap`) showing:
- 184 packets captured during demonstration
- Protocol distribution analysis
- Performance characteristics
- Traffic pattern analysis

### Analysis Tools
```bash
# View captured traffic
tcpdump -r rdma_traffic_capture.pcap

# Analyze with Wireshark
wireshark rdma_traffic_capture.pcap

# Filter specific protocols
tcpdump -r rdma_traffic_capture.pcap port 18515
```

## RDMA Traffic Simulation

The `simulated_rdma_traffic.txt` file contains detailed examples of:
- RDMA Write operations (4KB data transfer)
- RDMA Read requests and responses
- Send/Receive operations
- Atomic operations (Compare and Swap)
- Queue pair management
- Memory registration
- Completion notifications

## Troubleshooting

### Common Issues
1. **No RDMA devices found**: Check kernel modules and hardware
2. **Performance issues**: Monitor CPU usage and network utilization
3. **Connection problems**: Verify queue pair state and memory registration
4. **Traffic capture issues**: Check network interface and permissions

### Debugging Commands
```bash
# Check RDMA devices
ibv_devices
ibstat

# Monitor performance
htop
iostat -x 1

# Analyze network
ethtool -S eth0
netstat -i
```

## Real-World Implementation

### For Physical Hardware
1. Install RDMA-enabled hardware (Mellanox, Intel, etc.)
2. Load appropriate kernel modules
3. Configure network interfaces
4. Set up two-machine test environment

### For SoftRoCE
1. Load SoftRoCE kernel modules (`rxe`, `rdma_rxe`)
2. Create SoftRoCE devices
3. Configure network interfaces
4. Test with performance tools

## Contributing

Contributions are welcome! Please feel free to:
- Add new RDMA examples
- Improve performance testing
- Enhance traffic analysis
- Fix bugs or issues
- Add documentation

## License

This project is open source and available under the MIT License.

## References

- [RDMA Programming Guide](https://www.openfabrics.org/)
- [InfiniBand Architecture Specification](https://www.infinibandta.org/)
- [SoftRoCE Documentation](https://www.kernel.org/doc/Documentation/infiniband/)
- [RDMA Performance Tuning](https://www.mellanox.com/support/)

## Contact

For questions or support, please open an issue in this repository.

---

**Note**: This demonstration was created in a cloud environment without actual RDMA hardware. For real RDMA functionality, physical hardware or proper SoftRoCE setup is required.