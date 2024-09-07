#!/bin/bash

PROXY_LIST_URL="http://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt"
OUTPUT_FILE="proxy_pings.txt"

rm -f "$OUTPUT_FILE"

curl -s "$PROXY_LIST_URL" | while read -r proxy; do
  IFS=":" read -r ip port <<< "$proxy"
  
  # Check if the port is open
  if timeout 2 bash -c "</dev/tcp/$ip/$port" 2>/dev/null; then
    # Measure ping
    ping_time=$(ping -c 1 -W 1 $ip | awk -F'/' 'END{print $5}')
    if [ -z "$ping_time" ]; then
      ping_time="N/A"
    fi
  else
    ping_time="Port Closed"
  fi

  echo "$proxy $ping_time" >> "$OUTPUT_FILE"
done

if [ -f "$OUTPUT_FILE" ]; then
  sort -k2,2n "$OUTPUT_FILE" > sorted_"$OUTPUT_FILE"
  cat sorted_"$OUTPUT_FILE"
else
  echo "Output file $OUTPUT_FILE not found."
fi
