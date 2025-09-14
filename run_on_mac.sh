#!/bin/bash

# RDMA Application Runner for macOS
# This script helps you run the RDMA application on your Mac using Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                RDMA Application for macOS                   ║${NC}"
echo -e "${BLUE}║                    (Docker Container)                       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    echo ""
    echo "Please install Docker Desktop for Mac:"
    echo "1. Go to https://www.docker.com/products/docker-desktop/"
    echo "2. Download Docker Desktop for Mac"
    echo "3. Install and start Docker Desktop"
    echo "4. Run this script again"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running!${NC}"
    echo ""
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo -e "${GREEN}✅ Docker is installed and running${NC}"
echo ""

# Function to show menu
show_menu() {
    echo -e "${CYAN}Choose an option:${NC}"
    echo "1. Build and run Docker container"
    echo "2. Run existing container"
    echo "3. Run demo inside container"
    echo "4. Run full test suite"
    echo "5. Clean up containers"
    echo "6. Show container logs"
    echo "7. Exit"
    echo ""
}

# Function to build and run container
build_and_run() {
    echo -e "${YELLOW}Building Docker container...${NC}"
    docker build -t rdma-app .
    
    echo -e "${YELLOW}Starting container...${NC}"
    docker run -it --privileged --net=host --name rdma-demo rdma-app
}

# Function to run existing container
run_existing() {
    if docker ps -a --format "table {{.Names}}" | grep -q "rdma-demo"; then
        echo -e "${YELLOW}Starting existing container...${NC}"
        docker start rdma-demo
        docker exec -it rdma-demo /bin/bash
    else
        echo -e "${RED}No existing container found. Building new one...${NC}"
        build_and_run
    fi
}

# Function to run demo
run_demo() {
    echo -e "${YELLOW}Running demo inside container...${NC}"
    docker exec -it rdma-demo ./demo_simple.sh
}

# Function to run full test
run_full_test() {
    echo -e "${YELLOW}Running full test suite...${NC}"
    docker exec -it rdma-demo sudo ./run_test.sh
}

# Function to clean up
cleanup() {
    echo -e "${YELLOW}Cleaning up containers...${NC}"
    docker stop rdma-demo 2>/dev/null || true
    docker rm rdma-demo 2>/dev/null || true
    docker rmi rdma-app 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# Function to show logs
show_logs() {
    echo -e "${YELLOW}Container logs:${NC}"
    docker logs rdma-demo
}

# Main menu loop
while true; do
    show_menu
    read -p "Enter your choice (1-7): " choice
    
    case $choice in
        1)
            build_and_run
            ;;
        2)
            run_existing
            ;;
        3)
            run_demo
            ;;
        4)
            run_full_test
            ;;
        5)
            cleanup
            ;;
        6)
            show_logs
            ;;
        7)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    echo ""
done
