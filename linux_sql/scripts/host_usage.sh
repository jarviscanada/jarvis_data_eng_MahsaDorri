#!/bin/sh

# Setup and validate arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5


#* * * * * bash /home/rocky/dev/jrvs/bootcamp/linux_sql/host_agent/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log

# Check number of arguments
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

# Save machine statistics in MB and current machine hostname to variables
vmstat_mb=$(vmstat --unit M)
hostname=DEFAULT	

# Retrieve hardware specification variables
memory_free=$(echo "$vmstat_mb" | tail -1 | awk '{print $4}')
cpu_idle=$(echo "$vmstat_mb" | tail -1 | awk '{print $15}')
cpu_kernel=$(echo "$vmstat_mb" | tail -1 | awk '{print $14}')
disk_io=$(vmstat --unit M -d | tail -1 | awk '{print $10}')
disk_available=$(df -BM / | tail -1 | awk '{print $4}' | sed 's/M$//')

# Current time in `2019-11-26 14:40:19` UTC format
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Set up environment variable for psql password
export PGPASSWORD=$psql_password

# Retrieve host_id from host_info table based on hostname
host_id=$(psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -t -c "SELECT id FROM host_info WHERE hostname='$hostname';" | xargs)

# Check if host_id was retrieved; exit if not found
if [ -z "$host_id" ]; then
    echo "Error: HOST_ID not found for hostname '$hostname' in host_info table."
    exit 1
fi

# PSQL command: Insert server usage data into host_usage table
insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES('$timestamp', $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available');"

# Insert info into database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

# Check if the insert was successful
if [ $? -eq 0 ]; then
    echo "Data inserted successfully into host_usage table."
else
    echo "Failed to insert data into host_usage table."
fi

