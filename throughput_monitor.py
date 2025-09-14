#!/usr/bin/env python3
"""
RDMA RoCEv2 Throughput Monitor
This script monitors network throughput and analyzes RDMA traffic patterns
"""

import time
import psutil
import subprocess
import json
import argparse
import signal
import sys
from datetime import datetime
import threading
import queue

class ThroughputMonitor:
    def __init__(self, interface='eth0', duration=60, output_file='throughput_data.json'):
        self.interface = interface
        self.duration = duration
        self.output_file = output_file
        self.running = True
        self.data_points = []
        self.start_time = None
        self.end_time = None
        
        # Set up signal handlers
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
    
    def signal_handler(self, signum, frame):
        print(f"\nReceived signal {signum}, stopping monitor...")
        self.running = False
    
    def get_network_stats(self):
        """Get current network statistics for the interface"""
        try:
            stats = psutil.net_io_counters(pernic=True)
            if self.interface in stats:
                return stats[self.interface]
            else:
                # Try to find the interface
                for iface, stat in stats.items():
                    if iface.startswith('eth') or iface.startswith('en'):
                        self.interface = iface
                        return stat
        except Exception as e:
            print(f"Error getting network stats: {e}")
            return None
    
    def get_rdma_port_stats(self, port=18515):
        """Get statistics for RDMA ports using netstat/ss"""
        try:
            # Try ss first (more modern)
            result = subprocess.run(['ss', '-ulnp'], capture_output=True, text=True)
            if result.returncode == 0:
                lines = result.stdout.split('\n')
                port_stats = []
                for line in lines:
                    if f':{port}' in line or ':4791' in line:
                        port_stats.append(line.strip())
                return port_stats
        except FileNotFoundError:
            # Fallback to netstat
            try:
                result = subprocess.run(['netstat', '-ulnp'], capture_output=True, text=True)
                if result.returncode == 0:
                    lines = result.stdout.split('\n')
                    port_stats = []
                    for line in lines:
                        if f':{port}' in line or ':4791' in line:
                            port_stats.append(line.strip())
                    return port_stats
            except FileNotFoundError:
                pass
        return []
    
    def calculate_throughput(self, prev_stats, curr_stats, time_diff):
        """Calculate throughput between two measurement points"""
        if not prev_stats or not curr_stats:
            return 0, 0
        
        bytes_sent_diff = curr_stats.bytes_sent - prev_stats.bytes_sent
        bytes_recv_diff = curr_stats.bytes_recv - prev_stats.bytes_recv
        
        # Calculate rates in Mbps
        send_rate = (bytes_sent_diff * 8) / (time_diff * 1e6) if time_diff > 0 else 0
        recv_rate = (bytes_recv_diff * 8) / (time_diff * 1e6) if time_diff > 0 else 0
        
        return send_rate, recv_rate
    
    def monitor_loop(self):
        """Main monitoring loop"""
        print(f"Starting throughput monitoring on interface {self.interface}")
        print(f"Duration: {self.duration} seconds")
        print("Press Ctrl+C to stop early")
        
        self.start_time = time.time()
        prev_stats = None
        prev_time = self.start_time
        
        while self.running and (time.time() - self.start_time) < self.duration:
            current_time = time.time()
            time_diff = current_time - prev_time
            
            # Get current network statistics
            curr_stats = self.get_network_stats()
            if curr_stats:
                # Calculate throughput
                if prev_stats:
                    send_rate, recv_rate = self.calculate_throughput(prev_stats, curr_stats, time_diff)
                    
                    # Get RDMA port statistics
                    port_stats = self.get_rdma_port_stats()
                    
                    # Create data point
                    data_point = {
                        'timestamp': current_time,
                        'elapsed_time': current_time - self.start_time,
                        'bytes_sent': curr_stats.bytes_sent,
                        'bytes_recv': curr_stats.bytes_recv,
                        'packets_sent': curr_stats.packets_sent,
                        'packets_recv': curr_stats.packets_recv,
                        'send_rate_mbps': send_rate,
                        'recv_rate_mbps': recv_rate,
                        'total_rate_mbps': send_rate + recv_rate,
                        'port_stats': port_stats
                    }
                    
                    self.data_points.append(data_point)
                    
                    # Print real-time stats
                    print(f"\r[{current_time - self.start_time:6.1f}s] "
                          f"TX: {send_rate:6.2f} Mbps | "
                          f"RX: {recv_rate:6.2f} Mbps | "
                          f"Total: {send_rate + recv_rate:6.2f} Mbps", end='', flush=True)
                
                prev_stats = curr_stats
                prev_time = current_time
            
            time.sleep(0.1)  # 10 Hz sampling rate
        
        self.end_time = time.time()
        print(f"\nMonitoring completed after {self.end_time - self.start_time:.1f} seconds")
    
    def analyze_results(self):
        """Analyze the collected data and generate statistics"""
        if not self.data_points:
            print("No data points collected")
            return
        
        print("\n" + "="*60)
        print("THROUGHPUT ANALYSIS RESULTS")
        print("="*60)
        
        # Calculate statistics
        send_rates = [dp['send_rate_mbps'] for dp in self.data_points]
        recv_rates = [dp['recv_rate_mbps'] for dp in self.data_points]
        total_rates = [dp['total_rate_mbps'] for dp in self.data_points]
        
        # Remove outliers (rates > 1000 Mbps are likely measurement errors)
        send_rates = [r for r in send_rates if r < 1000]
        recv_rates = [r for r in recv_rates if r < 1000]
        total_rates = [r for r in total_rates if r < 1000]
        
        if send_rates:
            print(f"Send Rate Statistics:")
            print(f"  Average: {sum(send_rates)/len(send_rates):.2f} Mbps")
            print(f"  Peak:    {max(send_rates):.2f} Mbps")
            print(f"  Min:     {min(send_rates):.2f} Mbps")
        
        if recv_rates:
            print(f"Receive Rate Statistics:")
            print(f"  Average: {sum(recv_rates)/len(recv_rates):.2f} Mbps")
            print(f"  Peak:    {max(recv_rates):.2f} Mbps")
            print(f"  Min:     {min(recv_rates):.2f} Mbps")
        
        if total_rates:
            print(f"Total Rate Statistics:")
            print(f"  Average: {sum(total_rates)/len(total_rates):.2f} Mbps")
            print(f"  Peak:    {max(total_rates):.2f} Mbps")
            print(f"  Min:     {min(total_rates):.2f} Mbps")
        
        # Calculate total data transferred
        if len(self.data_points) > 1:
            first = self.data_points[0]
            last = self.data_points[-1]
            total_sent = last['bytes_sent'] - first['bytes_sent']
            total_recv = last['bytes_recv'] - first['bytes_recv']
            total_time = last['elapsed_time'] - first['elapsed_time']
            
            print(f"\nTotal Data Transferred:")
            print(f"  Sent:    {total_sent / 1e6:.2f} MB")
            print(f"  Received: {total_recv / 1e6:.2f} MB")
            print(f"  Total:   {(total_sent + total_recv) / 1e6:.2f} MB")
            
            if total_time > 0:
                avg_throughput = ((total_sent + total_recv) * 8) / (total_time * 1e6)
                print(f"  Average Throughput: {avg_throughput:.2f} Mbps")
        
        # RDMA-specific analysis
        rdma_packets = 0
        for dp in self.data_points:
            if dp['port_stats']:
                rdma_packets += len(dp['port_stats'])
        
        print(f"\nRDMA Traffic:")
        print(f"  Port 18515 (RDMA CM) activity detected: {rdma_packets > 0}")
        print(f"  Port 4791 (RoCEv2) activity detected: {any('4791' in str(dp['port_stats']) for dp in self.data_points)}")
    
    def save_results(self):
        """Save results to JSON file"""
        results = {
            'interface': self.interface,
            'duration': self.duration,
            'start_time': self.start_time,
            'end_time': self.end_time,
            'data_points': self.data_points,
            'summary': self.get_summary()
        }
        
        with open(self.output_file, 'w') as f:
            json.dump(results, f, indent=2)
        
        print(f"\nResults saved to: {self.output_file}")
    
    def get_summary(self):
        """Get summary statistics"""
        if not self.data_points:
            return {}
        
        send_rates = [dp['send_rate_mbps'] for dp in self.data_points if dp['send_rate_mbps'] < 1000]
        recv_rates = [dp['recv_rate_mbps'] for dp in self.data_points if dp['recv_rate_mbps'] < 1000]
        total_rates = [dp['total_rate_mbps'] for dp in self.data_points if dp['total_rate_mbps'] < 1000]
        
        summary = {}
        
        if send_rates:
            summary['send_rate'] = {
                'avg': sum(send_rates) / len(send_rates),
                'peak': max(send_rates),
                'min': min(send_rates)
            }
        
        if recv_rates:
            summary['recv_rate'] = {
                'avg': sum(recv_rates) / len(recv_rates),
                'peak': max(recv_rates),
                'min': min(recv_rates)
            }
        
        if total_rates:
            summary['total_rate'] = {
                'avg': sum(total_rates) / len(total_rates),
                'peak': max(total_rates),
                'min': min(total_rates)
            }
        
        return summary

def main():
    parser = argparse.ArgumentParser(description='RDMA RoCEv2 Throughput Monitor')
    parser.add_argument('-i', '--interface', default='eth0', help='Network interface to monitor')
    parser.add_argument('-d', '--duration', type=int, default=60, help='Monitoring duration in seconds')
    parser.add_argument('-o', '--output', default='throughput_data.json', help='Output JSON file')
    parser.add_argument('--analyze', help='Analyze existing JSON file')
    
    args = parser.parse_args()
    
    if args.analyze:
        # Analyze existing file
        try:
            with open(args.analyze, 'r') as f:
                data = json.load(f)
            
            print("Analyzing existing data...")
            print(f"Interface: {data.get('interface', 'unknown')}")
            print(f"Duration: {data.get('duration', 'unknown')} seconds")
            
            if 'summary' in data:
                summary = data['summary']
                for rate_type, stats in summary.items():
                    print(f"\n{rate_type.upper()} Rate:")
                    print(f"  Average: {stats['avg']:.2f} Mbps")
                    print(f"  Peak:    {stats['peak']:.2f} Mbps")
                    print(f"  Min:     {stats['min']:.2f} Mbps")
        except Exception as e:
            print(f"Error analyzing file: {e}")
            return 1
    else:
        # Run monitoring
        monitor = ThroughputMonitor(
            interface=args.interface,
            duration=args.duration,
            output_file=args.output
        )
        
        try:
            monitor.monitor_loop()
            monitor.analyze_results()
            monitor.save_results()
        except KeyboardInterrupt:
            print("\nMonitoring interrupted by user")
            monitor.analyze_results()
            monitor.save_results()
        except Exception as e:
            print(f"Error during monitoring: {e}")
            return 1
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
