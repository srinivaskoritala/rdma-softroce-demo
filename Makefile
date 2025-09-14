# RDMA RoCEv2 Application Makefile

CC = gcc
CFLAGS = -Wall -Wextra -O2 -g
LDFLAGS = -libverbs -lrdmacm -lpthread

# Source files
SERVER_SRC = rdma_server.c
CLIENT_SRC = rdma_client.c

# Executables
SERVER_BIN = rdma_server
CLIENT_BIN = rdma_client

# Object files
SERVER_OBJ = $(SERVER_SRC:.c=.o)
CLIENT_OBJ = $(CLIENT_SRC:.c=.o)

# Default target
all: $(SERVER_BIN) $(CLIENT_BIN)

# Build server
$(SERVER_BIN): $(SERVER_OBJ)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

# Build client
$(CLIENT_BIN): $(CLIENT_OBJ)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

# Compile object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean build artifacts
clean:
	rm -f $(SERVER_OBJ) $(CLIENT_OBJ) $(SERVER_BIN) $(CLIENT_BIN)
	rm -f *.pcap *.txt *.json

# Install dependencies (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install -y \
		libibverbs-dev \
		librdmacm-dev \
		tcpdump \
		tshark \
		python3 \
		python3-psutil \
		bc

# Install dependencies (CentOS/RHEL/Fedora)
install-deps-rhel:
	sudo yum install -y \
		libibverbs-devel \
		librdmacm-devel \
		tcpdump \
		wireshark \
		python3 \
		python3-psutil \
		bc

# Check system requirements
check-requirements:
	@echo "Checking system requirements..."
	@echo -n "Checking for RDMA devices: "
	@if [ -d /sys/class/infiniband ]; then \
		echo "✓ Found"; \
		ls /sys/class/infiniband/; \
	else \
		echo "✗ Not found - RDMA devices not available"; \
	fi
	@echo -n "Checking for libibverbs: "
	@if pkg-config --exists libibverbs; then \
		echo "✓ Found"; \
	else \
		echo "✗ Not found - install libibverbs-dev"; \
	fi
	@echo -n "Checking for librdmacm: "
	@if pkg-config --exists librdmacm; then \
		echo "✓ Found"; \
	else \
		echo "✗ Not found - install librdmacm-dev"; \
	fi
	@echo -n "Checking for tcpdump: "
	@if command -v tcpdump >/dev/null 2>&1; then \
		echo "✓ Found"; \
	else \
		echo "✗ Not found - install tcpdump"; \
	fi
	@echo -n "Checking for Python3: "
	@if command -v python3 >/dev/null 2>&1; then \
		echo "✓ Found"; \
	else \
		echo "✗ Not found - install python3"; \
	fi

# Run server in background
run-server: $(SERVER_BIN)
	@echo "Starting RDMA server..."
	./$(SERVER_BIN) &

# Run client
run-client: $(CLIENT_BIN)
	@echo "Starting RDMA client..."
	./$(CLIENT_BIN)

# Run with packet capture
run-with-capture: $(SERVER_BIN) $(CLIENT_BIN)
	@echo "Starting RDMA application with packet capture..."
	@echo "This will run for 60 seconds and capture packets"
	sudo ./capture_rdma_traffic.sh capture &
	sleep 2
	./$(SERVER_BIN) &
	sleep 1
	./$(CLIENT_BIN)
	wait

# Run throughput monitoring
run-monitor: $(SERVER_BIN) $(CLIENT_BIN)
	@echo "Starting RDMA application with throughput monitoring..."
	python3 throughput_monitor.py -d 60 -o throughput_results.json &
	sleep 2
	./$(SERVER_BIN) &
	sleep 1
	./$(CLIENT_BIN)
	wait

# Full test with both capture and monitoring
test-full: $(SERVER_BIN) $(CLIENT_BIN)
	@echo "Running full test with packet capture and throughput monitoring..."
	sudo ./capture_rdma_traffic.sh capture &
	python3 throughput_monitor.py -d 60 -o throughput_results.json &
	sleep 2
	./$(SERVER_BIN) &
	sleep 1
	./$(CLIENT_BIN)
	wait
	@echo "Test completed. Check rdma_capture.pcap and throughput_results.json for results."

# Stop all running processes
stop:
	@echo "Stopping all RDMA processes..."
	-pkill -f rdma_server
	-pkill -f rdma_client
	-pkill -f capture_rdma_traffic
	-pkill -f throughput_monitor

# Show help
help:
	@echo "RDMA RoCEv2 Application Makefile"
	@echo "================================="
	@echo ""
	@echo "Available targets:"
	@echo "  all              - Build server and client"
	@echo "  $(SERVER_BIN)     - Build server only"
	@echo "  $(CLIENT_BIN)     - Build client only"
	@echo "  clean            - Remove build artifacts"
	@echo "  install-deps     - Install dependencies (Ubuntu/Debian)"
	@echo "  install-deps-rhel - Install dependencies (CentOS/RHEL/Fedora)"
	@echo "  check-requirements - Check system requirements"
	@echo "  run-server       - Run server in background"
	@echo "  run-client       - Run client"
	@echo "  run-with-capture - Run with packet capture"
	@echo "  run-monitor      - Run with throughput monitoring"
	@echo "  test-full        - Run full test with both capture and monitoring"
	@echo "  stop             - Stop all running processes"
	@echo "  help             - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make check-requirements  # Check if system is ready"
	@echo "  make install-deps        # Install required packages"
	@echo "  make all                 # Build the application"
	@echo "  make test-full           # Run complete test"

.PHONY: all clean install-deps install-deps-rhel check-requirements run-server run-client run-with-capture run-monitor test-full stop help
