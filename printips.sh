input_file="nodes"
while IFS= read -r ip_address; do
    echo "Executing commands on $ip_address..."
done < "$input_file"