#!/bin/bash
# syshealth.sh - System Health Report Script
# Author: Sunday Nwabiani | Portfolio: github.com/komabiani/devops-portfolio

set -euo pipefail
# exit on error, unrefined variable, or pipe failure

REPORT_FILE="/tmp/syshealth-$(date +%Y%m%d-%H%M%S).txt"
THRESHOLD_CPU=80
THRESHOLD_DISK=85
THRESHOLD_MEM=90

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$REPORT_FILE"; }

log '===== SYSTEM HEALTH REPORT ====='
log "Hostname: $(hostname)"
log "Uptime: $(uptime -p)"
log "Kernel: $(uname -r)"

# CPU Check
CPU=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1)
log "CPU Usage: ${CPU}%"
if (( $(echo "$CPU > $THRESHOLD_CPU" | bc -l) )); then
       log 'WARNING: CPU usage is HIGH'
fi

# Memory Check
MEM=$(free | awk '/Mem/{printf("%.0f"), $3/$2*100}')
log "Memory Usage: ${MEM}%"
if [ "$MEM" -gt "$THRESHOLD_MEM" ]; then
	log 'WARNING: Memory Usage is HIGH'
fi


# Disk Check
df -h | grep -vE 'tmpfs|udev' | tail -n +2 | while read line; do
   USE=$(echo $line | awk '{print $5}' | tr -d '%')
   MOUNT=$(echo $line | awk '{print $6}')
   if [ "$USE" -gt "$THRESHOLD_DISK" ]; then
	  log "WARNING: Disk $MOUNT is at ${USE}%"
  else 
	 log "DISK $MOUNT: ${USE}% used"
  fi
done


# Top 5 processes by memory
log '--- Top 5 Memory Consumers ---'
ps aux --sort=-%mem | awk 'NR<=6 {print $0}' | tee -a "$REPORT_FILE"


# Check critical servives
SERVICES=(ssh cron)
for svc in "${SERVICES[@]}"; do
	if systemctl is-active --quiet "$svc"; then
		log "Service $svc: is RUNNING"
	else
		log "ALERT: $svc is NOT running"
		fi

	done

	log "Report saved to: $REPORT_FILE"
	log '===== END OF REPORT ===='
	

