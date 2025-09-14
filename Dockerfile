# RDMA Application Docker Container for macOS
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    pkg-config \
    libibverbs-dev \
    librdmacm-dev \
    tcpdump \
    tshark \
    python3 \
    python3-pip \
    python3-psutil \
    bc \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install --no-cache-dir psutil

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Make scripts executable
RUN chmod +x *.sh *.py

# Build the application
RUN make clean all

# Create results directory
RUN mkdir -p results

# Expose ports
EXPOSE 18515 4791

# Set default command
CMD ["/bin/bash"]
