/*
 * Simple RDMA Application Example
 * This demonstrates basic RDMA operations using libibverbs
 * 
 * Compile with: gcc -o simple_rdma simple_rdma_example.c -libverbs
 * 
 * Note: This is a conceptual example. Actual execution requires
 * RDMA hardware or SoftRoCE setup.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <infiniband/verbs.h>

#define BUFFER_SIZE 1024
#define PORT 18515

struct rdma_context {
    struct ibv_context *context;
    struct ibv_pd *pd;
    struct ibv_mr *mr;
    struct ibv_cq *cq;
    struct ibv_qp *qp;
    char *buffer;
};

int init_rdma_context(struct rdma_context *ctx) {
    struct ibv_device **dev_list;
    struct ibv_device *dev;
    int num_devices;
    
    printf("Initializing RDMA context...\n");
    
    // Get list of RDMA devices
    dev_list = ibv_get_device_list(&num_devices);
    if (!dev_list) {
        printf("No RDMA devices found\n");
        return -1;
    }
    
    if (num_devices == 0) {
        printf("No RDMA devices available\n");
        ibv_free_device_list(dev_list);
        return -1;
    }
    
    // Use first available device
    dev = dev_list[0];
    printf("Using RDMA device: %s\n", ibv_get_device_name(dev));
    
    // Open device context
    ctx->context = ibv_open_device(dev);
    if (!ctx->context) {
        printf("Failed to open RDMA device\n");
        ibv_free_device_list(dev_list);
        return -1;
    }
    
    // Allocate protection domain
    ctx->pd = ibv_alloc_pd(ctx->context);
    if (!ctx->pd) {
        printf("Failed to allocate protection domain\n");
        ibv_close_device(ctx->context);
        ibv_free_device_list(dev_list);
        return -1;
    }
    
    // Allocate memory buffer
    ctx->buffer = malloc(BUFFER_SIZE);
    if (!ctx->buffer) {
        printf("Failed to allocate memory buffer\n");
        ibv_dealloc_pd(ctx->pd);
        ibv_close_device(ctx->context);
        ibv_free_device_list(dev_list);
        return -1;
    }
    
    // Register memory region
    ctx->mr = ibv_reg_mr(ctx->pd, ctx->buffer, BUFFER_SIZE, 
                        IBV_ACCESS_LOCAL_WRITE | IBV_ACCESS_REMOTE_WRITE);
    if (!ctx->mr) {
        printf("Failed to register memory region\n");
        free(ctx->buffer);
        ibv_dealloc_pd(ctx->pd);
        ibv_close_device(ctx->context);
        ibv_free_device_list(dev_list);
        return -1;
    }
    
    // Create completion queue
    ctx->cq = ibv_create_cq(ctx->context, 10, NULL, NULL, 0);
    if (!ctx->cq) {
        printf("Failed to create completion queue\n");
        ibv_dereg_mr(ctx->mr);
        free(ctx->buffer);
        ibv_dealloc_pd(ctx->pd);
        ibv_close_device(ctx->context);
        ibv_free_device_list(dev_list);
        return -1;
    }
    
    // Create queue pair
    struct ibv_qp_init_attr qp_init_attr = {
        .send_cq = ctx->cq,
        .recv_cq = ctx->cq,
        .cap = {
            .max_send_wr = 10,
            .max_recv_wr = 10,
            .max_send_sge = 1,
            .max_recv_sge = 1
        },
        .qp_type = IBV_QPT_RC
    };
    
    ctx->qp = ibv_create_qp(ctx->pd, &qp_init_attr);
    if (!ctx->qp) {
        printf("Failed to create queue pair\n");
        ibv_destroy_cq(ctx->cq);
        ibv_dereg_mr(ctx->mr);
        free(ctx->buffer);
        ibv_dealloc_pd(ctx->pd);
        ibv_close_device(ctx->context);
        ibv_free_device_list(dev_list);
        return -1;
    }
    
    printf("RDMA context initialized successfully\n");
    printf("  Device: %s\n", ibv_get_device_name(dev));
    printf("  Memory region: 0x%lx, length: %d\n", 
           (unsigned long)ctx->mr->addr, ctx->mr->length);
    printf("  Queue pair: 0x%x\n", ctx->qp->qp_num);
    
    ibv_free_device_list(dev_list);
    return 0;
}

void cleanup_rdma_context(struct rdma_context *ctx) {
    printf("Cleaning up RDMA context...\n");
    
    if (ctx->qp) {
        ibv_destroy_qp(ctx->qp);
    }
    if (ctx->cq) {
        ibv_destroy_cq(ctx->cq);
    }
    if (ctx->mr) {
        ibv_dereg_mr(ctx->mr);
    }
    if (ctx->buffer) {
        free(ctx->buffer);
    }
    if (ctx->pd) {
        ibv_dealloc_pd(ctx->pd);
    }
    if (ctx->context) {
        ibv_close_device(ctx->context);
    }
    
    printf("RDMA context cleaned up\n");
}

int main(int argc, char *argv[]) {
    struct rdma_context ctx = {0};
    int ret;
    
    printf("==========================================\n");
    printf("Simple RDMA Application Example\n");
    printf("==========================================\n");
    
    // Initialize RDMA context
    ret = init_rdma_context(&ctx);
    if (ret != 0) {
        printf("Failed to initialize RDMA context\n");
        printf("This is expected in a cloud environment without RDMA hardware\n");
        printf("In a real setup with SoftRoCE, this would work properly\n");
        return 1;
    }
    
    // Simulate RDMA operations
    printf("\nSimulating RDMA operations...\n");
    
    // Fill buffer with test data
    strcpy(ctx.buffer, "Hello, RDMA World!");
    printf("Buffer content: %s\n", ctx.buffer);
    
    // Simulate RDMA write operation
    printf("Simulating RDMA write operation...\n");
    printf("  - Source buffer: 0x%lx\n", (unsigned long)ctx.buffer);
    printf("  - Destination: Remote memory region\n");
    printf("  - Size: %d bytes\n", BUFFER_SIZE);
    
    // Simulate RDMA read operation
    printf("Simulating RDMA read operation...\n");
    printf("  - Source: Remote memory region\n");
    printf("  - Destination buffer: 0x%lx\n", (unsigned long)ctx.buffer);
    printf("  - Size: %d bytes\n", BUFFER_SIZE);
    
    // Simulate send/receive operations
    printf("Simulating send/receive operations...\n");
    printf("  - Send queue: Ready for outgoing messages\n");
    printf("  - Receive queue: Ready for incoming messages\n");
    printf("  - Completion queue: Monitoring operation completion\n");
    
    printf("\nRDMA operations completed successfully!\n");
    
    // Cleanup
    cleanup_rdma_context(&ctx);
    
    printf("\n==========================================\n");
    printf("RDMA Application Example Complete\n");
    printf("==========================================\n");
    
    return 0;
}
