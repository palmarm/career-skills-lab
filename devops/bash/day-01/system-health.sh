#!/bin/bash

echo "System Health Check"
echo "==================="

current_user="$(whoami)"
current_dir="$(pwd)"
current_date="$(date)"

echo "User: $current_user"
echo "Directory: $current_dir"
echo "Date: $current_date"

hostname_name="$(hostname)"
uptime_info="$(uptime -p)"

echo "Hostname: $hostname_name"
echo "Uptime: $uptime_info"

echo
echo "Disk usage:"
df -h /

echo
echo "Memory:"
free -h


if ls /home >/dev/null 2>&1
then
    echo "Home directory check: PASS"
else
    echo "Home directory check: FAIL"
fi

#Disk health check
disk_usage="$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')"

echo
echo "Disk Health Check:"

if [ "$disk_usage" -ge 80 ]
then
    echo "Disk status: WARNING - ${disk_usage}% used"
else
    echo "Disk status: HEALTHY - ${disk_usage}% used"
fi

#Memory Health check
mem_usage="$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')"

echo "Memory Health Check:"

if [ "$mem_usage" -ge 80 ]
then
	echo "Memory status: WARNING  - ${mem_usage}% used"
else
	echo "memory status: HEALTHY - ${mem_usage}% used"
fi
