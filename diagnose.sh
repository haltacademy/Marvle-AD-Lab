#!/bin/bash
echo "=== CONTAINER STATUS ==="
sudo docker ps -a
echo ""

echo "=== MACHINE 1 LOGS (last 50 lines) ==="
sudo docker logs --tail 50 target_machine1
echo ""

echo "=== MACHINE 2 (AD DC) LOGS (last 50 lines) ==="
sudo docker logs --tail 50 target_machine2
echo ""

echo "=== MACHINE 1 RUNNING PROCESSES ==="
sudo docker exec target_machine1 ps aux 2>/dev/null || echo "Machine 1 not running"
echo ""

echo "=== MACHINE 2 RUNNING PROCESSES ==="
sudo docker exec target_machine2 ps aux 2>/dev/null || echo "Machine 2 not running"
echo ""

echo "=== MACHINE 1 SUPERVISORD LOGS ==="
sudo docker exec target_machine1 cat /var/log/supervisord.log 2>/dev/null || echo "No supervisord log file found"
echo ""

echo "=== MACHINE 1 SERVICE ERROR LOGS ==="
for service in ssh nginx vsftpd smbd mysql postfix mountd; do
    echo "--- $service error log ---"
    sudo docker exec target_machine1 cat /var/log/supervisor_${service}_err.log 2>/dev/null || echo "No log for $service"
done
