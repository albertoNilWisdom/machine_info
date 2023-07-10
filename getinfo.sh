#!/bin/bash

# Get the hostname
hostname=$(hostname)

# Get IP address of the machine
ip_address=$(hostname -I | awk '{print $1}')

# Get connected drives and their mount points
drives=$(lsblk -o NAME,MOUNTPOINT | grep -v NAME)

# Get storage capacity of each drive
drive_capacities=""
while IFS= read -r drive; do
    drive_name=$(echo "$drive" | awk '{print $1}')
    mount_point=$(echo "$drive" | awk '{print $2}')
    capacity=$(df -h --output=size "$mount_point" | tail -n 1)
    drive_capacities+="\n- $drive_name: $capacity"
done <<< "$drives"

# Get total storage capacity of the machine
total_storage_capacity=$(df -h --total | grep total | awk '{print $2}')

# Get processor type, GHz, and cores
processor_type=$(cat /proc/cpuinfo | grep 'model name' | head -n 1 | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')
processor_ghz=$(cat /proc/cpuinfo | grep 'cpu MHz' | head -n 1 | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')
processor_cores=$(nproc)

# Get RAM type and capacity in GB
ram_type=$(dmidecode -t memory | grep "Type:" | head -n 1 | awk '{print $2}')
ram_capacity=$(free -h | grep Mem | awk '{print $2}')

# Create the Markdown output
output="# $hostname System Information\n\n"
output+="## Machine Information\n"
output+="- Hostname: $hostname\n"
output+="- IP Address: $ip_address\n\n"
output+="## Drives\n"
output+="\`\`\`\n$drives\n\`\`\`\n\n"
output+="## Storage Capacity\n"
output+="$drive_capacities\n"
output+="- Total: $total_storage_capacity\n\n"
output+="## Processor Information\n"
output+="- Type: $processor_type\n"
output+="- GHz: $processor_ghz\n"
output+="- Cores: $processor_cores\n\n"
output+="## RAM Information\n"
output+="- Type: $ram_type\n"
output+="- Capacity: $ram_capacity\n"

# Save the Markdown output to a file named after the hostname
output_file="$hostname.md"
echo -e "$output" > "$output_file"

echo "Markdown output has been saved to $output_file"
