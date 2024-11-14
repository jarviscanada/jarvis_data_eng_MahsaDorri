# Cluster Monitoring System

## Introduction

This project implements a cluster monitoring architecture where multiple nodes utilize Bash scripts to collect essential system metrics, including CPU usage, memory consumption, and disk space. These metrics are transmitted to a central database through a network switch, enabling consolidated, local monitoring of the cluster's performance. By providing insight into Linux system monitoring and database management, this project offers a hands-on experience in developing a custom monitoring solution. The focus is on Bash scripting for data collection and PostgreSQL for data storage, providing a comprehensive understanding of both system monitoring and database interaction.

## Key Technologies

- **Linux Command Lines and Bash Scripts**: For gathering system metrics and automating processes.
- **PostgreSQL**: As the central database for storing and analyzing monitoring data.
- **Crontab**: For scheduling regular metric collection and ensuring data consistency.
- **GitHub and Git**: For version control and collaborative development.
- **Docker**: To set up and manage the PostgreSQL instance and ensure environment consistency.


## Quick Start

Follow these steps to set up and run the Linux Cluster Monitoring Agent:

1. **Start the PostgreSQL Database**
   - Use the `psql_docker.sh` script to start a PostgreSQL instance within Docker.
   
   ```bash
   ./scripts/psql_docker.sh start
   
2. **Create tables using ddl.sql**
   - Open and execute the `ddl.sql` file to create the necessary tables in the database.
  
   psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
   
3. **Insert Hardware Specs Data Into The DB**
   - Run the host_info.sh script to gather and insert the host's hardware specifications into the database. Replace localhost, 5432, host_agent, postgres, and password with your own PostgreSQL connection details.
   ```bash
   bash scripts/host_info.sh localhost 5432 host_agent postgres password

4. **Insert Hardware Specs Data Usage The DB**
   - Use the host_usage.sh script to start gathering real-time usage data (e.g., CPU and memory usage) and insert it into the database.
   ```bash
   bash scripts/host_usage.sh localhost 5432 host_agent postgres password
   
5. **Crontab Setup**
   - Use crontab to schedule periodic execution of the host_usage.sh script for continuous monitoring.
   ```bash
   crontab -e
   - Add the following line to schedule the script to run every minute (modify as needed):
     ```bash
   * * * * * bash /path/to/scripts/host_usage.sh localhost 5432 host_agent postgres password
    ```	

## Implementation

The Linux Cluster Monitoring Agent has been implemented using various technologies and tools to ensure efficient data collection and management. Here are the key components of the implementation:

- **Linux Command Lines and Bash Scripts**: The core functionality of the monitoring agent relies on Linux command lines and custom Bash scripts. These scripts were developed to capture hardware specifications and monitor resource usage on the Linux cluster.

- **PostgreSQL**: For storing and managing the collected data, PostgreSQL was chosen as the Relational Database Management System (RDBMS).

- **Crontab**: Automation plays a crucial role in ensuring timely data collection without manual intervention. To achieve this, Cron jobs were implemented to automate the execution of the monitoring agent's scripts. This approach guarantees consistent data collection at predefined intervals, providing up-to-date insights into the cluster's health and performance.

- **GitHub and Git**: GitHub served as the version control system for managing the source code. Git allows for collaborative development, code tracking, and easy rollbacks in case of issues or updates.

- **Docker**: Docker was employed to leverage the provisioning of the PostgreSQL database.

### Monitoring Agent Scripts

The monitoring agent includes two main scripts:

1. **`host_info.sh`**: 
   - This script gathers detailed hardware information about each host, including CPU architecture, memory, and the number of CPUs.
   - The data collected is inserted into the `host_info` table in the PostgreSQL database.
   - This script is designed to run only once during the initial setup to populate hardware details.

2. **`host_usage.sh`**:
   - This script collects real-time usage data, including CPU and memory usage for each host.
   - It is scheduled to run at regular intervals (e.g., every minute) using `cron`, enabling continuous monitoring of system performance.
   - The data collected is inserted into the `host_usage` table in the PostgreSQL database, allowing for time-based analysis of usage patterns.

By combining these technologies and tools, the Linux Cluster Monitoring Agent delivers an efficient and scalable solution for monitoring and managing a Linux cluster's performance and resource utilization.


## Architecture

The architecture of the Linux Cluster Monitoring System is modular and scalable, enabling data collection from multiple nodes while centralizing data storage for easy monitoring and analysis.

### System Components

1. **Monitoring Nodes**:
   - Each node in the cluster runs the `host_info.sh` and `host_usage.sh` scripts to collect data.
   - The scripts capture both static and dynamic system metrics and send them to the PostgreSQL database.
   
2. **Network Switch**:
   - The network switch connects all nodes in the cluster to the central database server, allowing the monitoring agents to transmit data in real-time.

3. **Centralized Database (PostgreSQL)**:
   - A Docker-managed PostgreSQL instance serves as the centralized repository for all monitoring data.
   - This database stores both hardware information and dynamic usage metrics, enabling comprehensive analysis of the cluster’s health and performance.

4. **Automated Scheduling (Crontab)**:
   - `Crontab` on each node ensures that the `host_usage.sh` script runs at regular intervals, allowing continuous data collection without manual intervention.

## Database Modeling Overview
The database is structured to monitor system performance and consists of two tables: `host_info` and host_usage. Each table captures different types of information:

1. `host_info` **Table** :
   **Purpose**: This table stores static, hardware-related information about each host machine. Since it records the hardware setup, it remains largely unchanged after the         initial entry.

   **Columns**:
   - **id**: Unique identifier for each host (auto-incremented primary key).
   - **hostname**: Fully qualified hostname, unique for each machine.
   - **cpu_number**: Number of CPU cores in the system.
   - **cpu_architecture**: The type of CPU architecture (e.g., x86_64, ARM).
   - **cpu_model**: Name of the CPU model (e.g., Intel(R) Xeon(R) CPU @ 2.30GHz).
   - **cpu_mhz**: CPU speed in megahertz (MHz).
   - **l2_cache**: Size of the L2 cache in kilobytes (KB).
   - **total_mem**: Total memory size in kilobytes (KB).
   - **timestamp**: Date and time when this information was recorded.

   This table is used to store the machine’s hardware configuration, making it possible to identify each host, compare configurations, and analyze system capacity based on         hardware specs.


2. `host_usage` **Table** :

   **Purpose**: This table captures dynamic, real-time metrics for each host. Every entry represents a snapshot of system metrics, allowing for trend analysis over time.

   **Columns**:
   - **timestamp**: Records the date and time when the usage data was collected.
   - **host_id**: Foreign key referencing id in the host_info table, linking usage data to the corresponding host.
   - **memory_free**: Amount of available memory in megabytes (MB).
   - **cpu_idle**: Percentage of CPU time spent idle.
   - **cpu_kernel**: Percentage of CPU time used by kernel processes.
   - **disk_io**: Number of disk I/O operations since the last snapshot.
   - **disk_available**: Available disk space in megabytes (MB).

   This table is used to store performance data over time, allowing for monitoring resource usage, identifying performance bottlenecks, and detecting potential issues based on     patterns in memory, CPU, and disk utilization.

   **Relationship**:
   The `host_usage` table links to the host_info table through the `host_id` foreign key, establishing a **one-to-many** relationship. Each host in `host_info` can have 
   multiple entries in `host_usage`, representing different snapshots of its system metrics over time.

## Testing:
   ### Testing Bash Scripts

1. **Using Debug Mode**
   - To debug the Bash scripts, use the `-x` option to display each command and its arguments as they are executed:
     ```bash
     bash -x ./scripts/host_usage.sh
     ```
## Deployment

The deployment of the Linux Cluster Monitoring Agent involves setting up the `host_usage.sh` script to run automatically:

1. **Configuring Execution Permissions**
   - Use the `chmod +x` command to make `host_usage.sh` executable:
     ```bash
     chmod +x ./scripts/host_usage.sh
     ```

2. **Scheduling with Crontab**
   - Schedule `host_usage.sh` to run at predefined intervals using `crontab`, automating the collection of server usage data:
     ```bash
     crontab -e
     ```	
## Improvements

To enhance the Linux Cluster Monitoring Agent?s functionality and resilience, consider these improvements:

 **Resource Cleanup Automation**
   - Implement scripts to periodically delete outdated records and clear unused files, keeping storage usage optimized.
 

   
