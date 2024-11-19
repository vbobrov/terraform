#!/bin/bash

# Function to generate a random MAC address
generate_mac() {
    hexchars="0123456789ABCDEF"
    echo "$(for i in {1..6}; do echo -n ${hexchars:$(( $RANDOM % 16 )):1}${hexchars:$(( $RANDOM % 16 )):1}; [ $i -lt 6 ] && echo -n ":"; done)"
}

# Number of iterations (adjust as needed)
iterations=500

# Replace with actual IP and password
server_ip="10.2.1.1"
shared_secret="cisco"

# Loop for specified number of iterations
for ((i=1; i<=iterations; i++))
do
    # Generate a random MAC address
    mac_address=$(generate_mac)
    echo $mac_address


    # Randomly decide whether to execute auth or acct or both
    if (( $RANDOM % 2 == 0 )); then
        # Run auth command randomly
        echo "Running auth command..."
        echo "User-Name:=cisco,User-Password=cisco,Calling-Station-Id=$mac_address" | radclient -x $server_ip auth $shared_secret
    fi

    if (( $RANDOM % 2 == 0 )); then
        # Run acct command randomly
        echo "Running acct command..."
        echo "User-Name:=cisco,User-Password=cisco,Calling-Station-Id=$mac_address" | radclient -x $server_ip acct $shared_secret
    fi

    # Add sleep if needed to avoid overwhelming the server (optional)
    # sleep 1
done
