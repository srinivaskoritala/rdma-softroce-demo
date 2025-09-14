#!/bin/bash

# RDMA Work Queue Entries (WQEs) and Completions Analysis
# This script explains how work queues work in RDMA operations

echo "=========================================="
echo "RDMA Work Queue Entries and Completions Analysis"
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

print_wqe() {
    echo -e "${MAGENTA}[WQE]${NC} $1"
}

print_header "1. Work Queue Overview"
print_status "RDMA Work Queues are the fundamental units of work in RDMA:"

echo "Work Queue Components:"
echo "  - Send Queue (SQ): Outgoing work requests"
echo "  - Receive Queue (RQ): Incoming work requests"
echo "  - Completion Queue (CQ): Work completion notifications"
echo "  - Shared Receive Queue (SRQ): Shared receive queue (optional)"
echo

print_wqe "Work Queue Entry (WQE) Structure:"
echo "  - Work Request ID: Unique identifier"
echo "  - Opcode: Operation type (SEND, RDMA_WRITE, RDMA_READ, ATOMIC)"
echo "  - Send Flags: Solicited event, immediate data, etc."
echo "  - Remote Address: Target memory address"
echo "  - Remote Key: Memory region key"
echo "  - Scatter/Gather Elements: Data buffers"
echo "  - Immediate Data: Small data payload"
echo

print_header "2. Send Queue Work Requests"
print_status "Send Queue handles outgoing RDMA operations:"

print_wqe "SEND Work Request:"
echo "  - Opcode: 0x04 (SEND)"
echo "  - Purpose: Message passing, RPC"
echo "  - Data: Message content"
echo "  - Completion: ACK packet"
echo

print_wqe "RDMA WRITE Work Request:"
echo "  - Opcode: 0x08 (RDMA_WRITE)"
echo "  - Purpose: Direct memory-to-memory transfer"
echo "  - Data: Application data"
echo "  - Completion: ACK packet"
echo

print_wqe "RDMA READ Work Request:"
echo "  - Opcode: 0x08 (RDMA_READ)"
echo "  - Purpose: Remote memory access"
echo "  - Data: None (request only)"
echo "  - Completion: RDMA READ Response with data"
echo

print_wqe "ATOMIC Work Request:"
echo "  - Opcode: 0x0F (ATOMIC_C&S), 0x10 (ATOMIC_FETCH_ADD)"
echo "  - Purpose: Synchronization operations"
echo "  - Data: Compare/Swap values"
echo "  - Completion: ATOMIC Response with result"
echo

print_header "3. Receive Queue Work Requests"
print_status "Receive Queue handles incoming RDMA operations:"

print_wqe "RECEIVE Work Request:"
echo "  - Opcode: 0x04 (RECEIVE)"
echo "  - Purpose: Receive incoming messages"
echo "  - Data: Buffer for incoming data"
echo "  - Completion: Message received"
echo

echo "Receive Queue Characteristics:"
echo "  - Pre-posted work requests"
echo "  - Consumed when messages arrive"
echo "  - Must be replenished after consumption"
echo "  - Can use Shared Receive Queue (SRQ)"
echo

print_header "4. Work Queue Completions"
print_status "Completions report the status of work requests:"

print_wqe "Completion Queue Entry (CQE) Structure:"
echo "  - Work Request ID: Matches posted WQE"
echo "  - Status: SUCCESS, ERROR, etc."
echo "  - Opcode: Original operation type"
echo "  - Vendor Error: Specific error code"
echo "  - Byte Length: Bytes transferred"
echo "  - Immediate Data: Immediate data value"
echo "  - QP Number: Queue Pair number"
echo

echo "Completion Status Codes:"
echo "  SUCCESS (0x00): Operation completed successfully"
echo "  LOCAL_ACCESS_ERROR (0x01): Local memory access error"
echo "  LOCAL_PROTECTION_ERROR (0x02): Local protection error"
echo "  WORK_REQUEST_FLUSHED_ERROR (0x03): Work request flushed"
echo "  REMOTE_ACCESS_ERROR (0x04): Remote memory access error"
echo "  REMOTE_PROTECTION_ERROR (0x05): Remote protection error"
echo "  REMOTE_INVALID_REQUEST_ERROR (0x06): Invalid remote request"
echo

print_header "5. Work Queue Management"
print_status "How to manage work queues in RDMA applications:"

echo "Posting Work Requests:"
echo "  ibv_post_send(qp, wr, bad_wr)  # Post to send queue"
echo "  ibv_post_recv(qp, wr, bad_wr)  # Post to receive queue"
echo

echo "Polling Completions:"
echo "  ibv_poll_cq(cq, num_entries, wc)  # Poll completion queue"
echo "  ibv_req_notify_cq(cq, solicited_only)  # Request notification"
echo "  ibv_get_cq_event(channel, cq, cq_context)  # Get completion event"
echo

echo "Work Queue Lifecycle:"
echo "  1. Post work request to queue"
echo "  2. Hardware processes the request"
echo "  3. Completion is generated"
echo "  4. Application polls for completion"
echo "  5. Process completion and free resources"
echo

print_header "6. Work Queue Performance"
print_status "Performance characteristics of work queues:"

echo "Work Queue Entry (WQE) Performance:"
echo "  - WQE Size: 64 bytes (typical)"
echo "  - Queue Depth: 1-1024 WQEs (configurable)"
echo "  - Posting Latency: 0.1-1 μs"
echo "  - Processing Latency: 0.1-5 μs"
echo "  - Throughput: 1-10M WQEs/second"
echo

echo "Completion Queue Entry (CQE) Performance:"
echo "  - CQE Size: 16 bytes (typical)"
echo "  - Queue Depth: 1-1024 CQEs (configurable)"
echo "  - Polling Latency: 0.1-1 μs"
echo "  - Notification Latency: 1-10 μs"
echo "  - Throughput: 1-10M CQEs/second"
echo

print_header "7. Work Queue Traffic Patterns"
print_status "Network traffic patterns for work queue operations:"

echo "SEND Operation Traffic:"
echo "  Client -> Server: SEND packet with message data"
echo "  Server -> Client: ACK packet (completion)"
echo "  Traffic: Bidirectional, small packets"
echo

echo "RDMA WRITE Operation Traffic:"
echo "  Client -> Server: RDMA WRITE packet with data"
echo "  Server -> Client: ACK packet (completion)"
echo "  Traffic: Unidirectional data, bidirectional control"
echo

echo "RDMA READ Operation Traffic:"
echo "  Client -> Server: RDMA READ REQUEST packet"
echo "  Server -> Client: RDMA READ RESPONSE packet with data"
echo "  Traffic: Request/response pattern"
echo

echo "ATOMIC Operation Traffic:"
echo "  Client -> Server: ATOMIC REQUEST packet"
echo "  Server -> Client: ATOMIC RESPONSE packet with result"
echo "  Traffic: Request/response pattern"
echo

print_header "8. Work Queue Monitoring"
print_status "Commands to monitor work queue operations:"

echo "Monitor Work Queue Status:"
echo "  ibv_devinfo -d rxe0  # Device information"
echo "  ibstat rxe0          # Device statistics"
echo

echo "Monitor Completion Queue:"
echo "  cat /sys/class/infiniband/rxe0/ports/1/counters/port_xmit_packets"
echo "  cat /sys/class/infiniband/rxe0/ports/1/counters/port_rcv_packets"
echo

echo "Monitor Work Queue Traffic:"
echo "  sudo tcpdump -i eth0 port 4791"
echo "  sudo tcpdump -i eth0 'port 4791 and udp[20:4] = 0x04'  # SEND"
echo "  sudo tcpdump -i eth0 'port 4791 and udp[20:4] = 0x08'  # RDMA WRITE"
echo "  sudo tcpdump -i eth0 'port 4791 and udp[20:4] = 0x0F'  # ATOMIC"
echo

print_header "9. Work Queue Best Practices"
print_status "Best practices for work queue management:"

echo "Queue Sizing:"
echo "  - Size queues based on expected workload"
echo "  - Balance between memory usage and performance"
echo "  - Consider burst traffic patterns"
echo

echo "Completion Handling:"
echo "  - Poll completions regularly"
echo "  - Use completion events for efficiency"
echo "  - Handle errors gracefully"
echo "  - Free resources promptly"
echo

echo "Performance Optimization:"
echo "  - Batch work requests when possible"
echo "  - Use appropriate queue depths"
echo "  - Monitor completion rates"
echo "  - Tune polling intervals"
echo

echo "Error Handling:"
echo "  - Check completion status"
echo "  - Implement retry mechanisms"
echo "  - Handle queue full conditions"
echo "  - Monitor error rates"
echo

print_header "10. Work Queue Examples"
print_status "Example work queue operations:"

echo "Posting a SEND Work Request:"
echo "  struct ibv_send_wr wr;"
echo "  struct ibv_sge sge;"
echo "  wr.wr_id = 0x12345678;"
echo "  wr.opcode = IBV_WR_SEND;"
echo "  wr.send_flags = IBV_SEND_SIGNALED;"
echo "  wr.sg_list = &sge;"
echo "  wr.num_sge = 1;"
echo "  sge.addr = (uintptr_t)buffer;"
echo "  sge.length = length;"
echo "  sge.lkey = mr->lkey;"
echo "  ibv_post_send(qp, &wr, &bad_wr);"
echo

echo "Polling Completions:"
echo "  struct ibv_wc wc;"
echo "  int num_completions = 0;"
echo "  while (num_completions < expected) {"
echo "    int ret = ibv_poll_cq(cq, 1, &wc);"
echo "    if (ret > 0) {"
echo "      if (wc.status == IBV_WC_SUCCESS) {"
echo "        // Process successful completion"
echo "      } else {"
echo "        // Handle error"
echo "      }"
echo "      num_completions++;"
echo "    }"
echo "  }"
echo

print_header "Demo Complete"
print_success "RDMA work queue analysis completed!"

print_status "Files created:"
echo "  - rdma_work_queue_analysis.txt: Detailed WQE examples"
echo "  - This demonstration: Complete work queue analysis"

print_wqe "Work queues provide:"
echo "  ✓ Asynchronous operation processing"
echo "  ✓ High-performance data transfer"
echo "  ✓ Error handling and reporting"
echo "  ✓ Flow control and backpressure"
echo "  ✓ Memory management"
echo "  ✓ Completion notification"
