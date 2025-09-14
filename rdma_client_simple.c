#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <infiniband/verbs.h>
#include <time.h>
#include <signal.h>

#define BUFFER_SIZE (1024 * 1024)  // 1MB buffer
#define PORT 18515

struct rdma_context {
    struct ibv_context *context;
    struct ibv_pd *pd;
    struct ibv_cq *cq;
    struct ibv_qp *qp;
    struct ibv_mr *mr;
    char *buffer;
    int connected;
    uint64_t bytes_transferred;
    struct timespec start_time, end_time;
};

static volatile int running = 1;

void signal_handler(int sig) {
    printf("\nReceived signal %d, shutting down...\n", sig);
    running = 0;
}

int setup_rdma_resources(struct rdma_context *ctx) {
    struct ibv_device **dev_list;
    int num_devices;
    struct ibv_device *device;
    struct ibv_qp_init_attr qp_init_attr;
    struct ibv_port_attr port_attr;
    
    // Get device list
    dev_list = ibv_get_device_list(&num_devices);
    if (!dev_list) {
        fprintf(stderr, "Failed to get IB device list\n");
        return -1;
    }
    
    if (num_devices == 0) {
        fprintf(stderr, "No IB devices found\n");
        return -1;
    }
    
    // Use first available device
    device = dev_list[0];
    printf("Using device: %s\n", ibv_get_device_name(device));
    
    // Open device context
    ctx->context = ibv_open_device(device);
    if (!ctx->context) {
        fprintf(stderr, "Failed to open device context\n");
        return -1;
    }
    
    // Allocate protection domain
    ctx->pd = ibv_alloc_pd(ctx->context);
    if (!ctx->pd) {
        fprintf(stderr, "Failed to allocate protection domain\n");
        return -1;
    }
    
    // Query port attributes
    if (ibv_query_port(ctx->context, 1, &port_attr)) {
        fprintf(stderr, "Failed to query port attributes\n");
        return -1;
    }
    
    printf("Port state: %s\n", ibv_port_state_str(port_attr.state));
    if (port_attr.state != IBV_PORT_ACTIVE) {
        fprintf(stderr, "Port is not active\n");
        return -1;
    }
    
    // Create completion queue
    ctx->cq = ibv_create_cq(ctx->context, 10, NULL, NULL, 0);
    if (!ctx->cq) {
        fprintf(stderr, "Failed to create completion queue\n");
        return -1;
    }
    
    // Allocate and register memory
    ctx->buffer = malloc(BUFFER_SIZE);
    if (!ctx->buffer) {
        fprintf(stderr, "Failed to allocate buffer\n");
        return -1;
    }
    
    // Fill buffer with test data
    for (int i = 0; i < BUFFER_SIZE; i++) {
        ctx->buffer[i] = (char)(i % 256);
    }
    
    ctx->mr = ibv_reg_mr(ctx->pd, ctx->buffer, BUFFER_SIZE, 
                        IBV_ACCESS_LOCAL_WRITE | IBV_ACCESS_REMOTE_WRITE | 
                        IBV_ACCESS_REMOTE_READ);
    if (!ctx->mr) {
        fprintf(stderr, "Failed to register memory region\n");
        return -1;
    }
    
    // Create queue pair
    memset(&qp_init_attr, 0, sizeof(qp_init_attr));
    qp_init_attr.qp_type = IBV_QPT_RC;
    qp_init_attr.send_cq = ctx->cq;
    qp_init_attr.recv_cq = ctx->cq;
    qp_init_attr.cap.max_send_wr = 10;
    qp_init_attr.cap.max_recv_wr = 10;
    qp_init_attr.cap.max_send_sge = 1;
    qp_init_attr.cap.max_recv_sge = 1;
    
    ctx->qp = ibv_create_qp(ctx->pd, &qp_init_attr);
    if (!ctx->qp) {
        fprintf(stderr, "Failed to create queue pair\n");
        return -1;
    }
    
    ibv_free_device_list(dev_list);
    return 0;
}

void perform_rdma_operations(struct rdma_context *ctx) {
    struct ibv_sge sge;
    struct ibv_send_wr send_wr, *bad_wr;
    struct ibv_wc wc;
    int ret;
    int iterations = 100;  // Reduced for demo
    int i;
    
    printf("Starting RDMA operations...\n");
    clock_gettime(CLOCK_MONOTONIC, &ctx->start_time);
    
    for (i = 0; i < iterations && running; i++) {
        // Prepare send work request
        memset(&sge, 0, sizeof(sge));
        sge.addr = (uintptr_t)ctx->buffer;
        sge.length = BUFFER_SIZE;
        sge.lkey = ctx->mr->lkey;
        
        memset(&send_wr, 0, sizeof(send_wr));
        send_wr.sg_list = &sge;
        send_wr.num_sge = 1;
        send_wr.opcode = IBV_WR_RDMA_WRITE;
        send_wr.send_flags = IBV_SEND_SIGNALED;
        send_wr.wr.rdma.remote_addr = (uintptr_t)ctx->buffer;
        send_wr.wr.rdma.rkey = ctx->mr->rkey;
        
        // Post send
        ret = ibv_post_send(ctx->qp, &send_wr, &bad_wr);
        if (ret) {
            fprintf(stderr, "Failed to post send: %d\n", ret);
            break;
        }
        
        // Wait for completion
        do {
            ret = ibv_poll_cq(ctx->cq, 1, &wc);
        } while (ret == 0 && running);
        
        if (ret < 0) {
            fprintf(stderr, "Failed to poll CQ\n");
            break;
        }
        
        if (wc.status != IBV_WC_SUCCESS) {
            fprintf(stderr, "Work completion error: %s\n", ibv_wc_status_str(wc.status));
            break;
        }
        
        ctx->bytes_transferred += BUFFER_SIZE;
        
        if (i % 10 == 0) {
            printf("Completed %d operations, %lu bytes transferred\n", 
                   i, ctx->bytes_transferred);
        }
    }
    
    clock_gettime(CLOCK_MONOTONIC, &ctx->end_time);
    
    // Calculate throughput
    double elapsed = (ctx->end_time.tv_sec - ctx->start_time.tv_sec) + 
                     (ctx->end_time.tv_nsec - ctx->start_time.tv_nsec) / 1e9;
    double throughput_mbps = (ctx->bytes_transferred * 8.0) / (elapsed * 1e6);
    
    printf("\n=== RDMA Performance Results ===\n");
    printf("Operations completed: %d\n", i);
    printf("Total bytes transferred: %lu\n", ctx->bytes_transferred);
    printf("Elapsed time: %.3f seconds\n", elapsed);
    printf("Throughput: %.2f Mbps\n", throughput_mbps);
    printf("Throughput: %.2f MB/s\n", ctx->bytes_transferred / (elapsed * 1e6));
}

void cleanup_rdma_resources(struct rdma_context *ctx) {
    if (ctx->qp) {
        ibv_destroy_qp(ctx->qp);
    }
    if (ctx->mr) {
        ibv_dereg_mr(ctx->mr);
    }
    if (ctx->cq) {
        ibv_destroy_cq(ctx->cq);
    }
    if (ctx->pd) {
        ibv_dealloc_pd(ctx->pd);
    }
    if (ctx->context) {
        ibv_close_device(ctx->context);
    }
    if (ctx->buffer) {
        free(ctx->buffer);
    }
}

int main(int argc, char *argv[]) {
    struct rdma_context ctx = {0};
    int ret;
    const char *server_ip = "127.0.0.1";
    
    if (argc > 1) {
        server_ip = argv[1];
    }
    
    // Set up signal handlers
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    printf("RDMA RoCEv2 Client Starting...\n");
    printf("Note: This is a simplified demo version\n");
    printf("Connecting to server at %s:%d\n", server_ip, PORT);
    
    // Set up RDMA resources
    ret = setup_rdma_resources(&ctx);
    if (ret) {
        fprintf(stderr, "Failed to set up RDMA resources\n");
        cleanup_rdma_resources(&ctx);
        return 1;
    }
    
    // Perform RDMA operations
    perform_rdma_operations(&ctx);
    
    // Cleanup
    cleanup_rdma_resources(&ctx);
    
    printf("RDMA client shutdown complete\n");
    return 0;
}
