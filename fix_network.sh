#!/bin/bash
# This script diagnoses and fixes the overlapping docker network issue for 172.168.1.0/24.

# Ensure the script is run with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo:"
  echo "sudo bash $0"
  exit 1
fi

echo "=== Searching for Docker networks overlapping with 172.168.1.0/24 ==="
# Get network IDs and names that use the 172.168.1.0/24 subnet
CONFLICTING_NETWORKS=$(docker network ls -q | while read -r net_id; do
    subnet=$(docker network inspect "$net_id" --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null)
    if [ "$subnet" = "172.168.1.0/24" ]; then
        name=$(docker network inspect "$net_id" --format '{{.Name}}')
        echo "$net_id:$name"
    fi
done)

if [ -z "$CONFLICTING_NETWORKS" ]; then
    echo "No Docker networks found using the subnet 172.168.1.0/24."
    echo "Checking if there are stale bridges on the host..."
    STALE_BRIDGE=$(ip route | grep "172.168.1.0/24" | awk '{print $3}')
    if [ -n "$STALE_BRIDGE" ]; then
        echo "Found stale host route/bridge: $STALE_BRIDGE"
        echo "Attempting to bring it down and delete it..."
        ip link set dev "$STALE_BRIDGE" down 2>/dev/null
        brctl delbr "$STALE_BRIDGE" 2>/dev/null || ip link delete dev "$STALE_BRIDGE" 2>/dev/null
        echo "Stale bridge removed."
    else
        echo "No stale host routes found for 172.168.1.0/24."
    fi
else
    echo "Found conflicting Docker network(s):"
    echo "$CONFLICTING_NETWORKS"
    echo ""
    
    # Loop through each conflicting network
    for net in $CONFLICTING_NETWORKS; do
        net_id="${net%%:*}"
        net_name="${net#*:}"
        
        echo "Analyzing network: $net_name ($net_id)"
        
        # Find containers attached to this network
        containers=$(docker network inspect "$net_id" --format '{{range $k, $v := .Containers}}{{$k}} {{end}}')
        if [ -n "$containers" ]; then
            echo "The following containers are attached to this network and must be stopped/removed:"
            for c_id in $containers; do
                c_name=$(docker inspect "$c_id" --format '{{.Name}}')
                echo "  - $c_name ($c_id)"
            done
            echo "Stopping and removing these containers..."
            docker rm -f $containers
        else
            echo "No active containers attached to this network."
        fi
        
        echo "Removing conflicting network $net_name..."
        docker network rm "$net_id"
    done
fi

echo ""
echo "=== Running docker network prune ==="
docker network prune -f

echo ""
echo "=== Try running docker compose up again ==="
echo "You can now run: sudo docker compose up -d --build"
