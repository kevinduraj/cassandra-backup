#!/bin/bash
#----------------------------------------------------------------------------------------------#
clear;

if [ "$#" -ne 8 ]; then
    echo
    echo "  $# incorrect number of parameters" 
    echo
    echo "  +-------------------------------------------------+"
    echo "  |            Execute on Backup Server             |"
    echo "  +-------------------------------------------------+"
    echo "  |               Required Parameters               |"
    echo "  +-------------------------------------------------+"
    echo "  | 1. Production Cluster Name                      |"
    echo "  | 2. Production DataCenter Name                   |"
    echo "  | 3. Production Rack Name                         |"
    echo "  | 4. Production Directory  eg: /var/lib/cassandra |"
    echo "  +-------------------------------------------------+"
    echo "  | 5. Backup Cluster Name                          |"
    echo "  | 6. Backup DataCenter Name                       |"
    echo "  | 7. Backup Rack Name                             |"
    echo "  | 8. Backup Directory      eg: /mnt/cassandra     |"
    echo "  +-------------------------------------------------+"
    echo
    echo "  ./2-update-system.sh 'Cluster1' 'DC1' 'RACK1' '/var/lib/cassandra' 'Cluster2' 'DC2' 'RACK2' '/mnt/cassandra'"
    echo    
    echo    
    exit
fi

echo "Executing ..."    
#----------------------------------------------------------------------------------------------#
SOURCE_CLUSTER=${1}               # Production Cluster Name
SOURCE_DC=${2}                    # Production DataCenter Name
SOURCE_RACK=${3}                  # Production Rack Name
SOURCE_DIRECTORY=${4}             # Production Directory '/var/lib/cassandra'
#----------------------------------------------------------------------------------------------#
DESTINATION_CLUSTER=${5}          # Backup Cluster Name
DESTINATION_DC=${6}               # Backup DataCenter Name
DESTINATION_RACK=${7}             # Backup Rack Name
DESTINATION_DIRECTORY=${8}        # Backup Directory     '/mnt/cassandra'
#----------------------------------------------------------------------------------------------#

#----------------------------------------------------------------------------------------------#
# Get Cassandra running with source cluster settings
#----------------------------------------------------------------------------------------------#
sed -i 's/phi_convict_threshold/#phi_convict_threshold/' /etc/dse/cassandra/cassandra.yaml
#----------------------------------------------------------------------------------------------#
sed -i 's/$DESTINATION_CLUSTER/$SOURCE_CLUSTER/' /etc/dse/cassandra/cassandra.yaml
sed -i 's/$DESTINATION_DC/$SOURCE_DC/'  /etc/dse/cassandra/cassandra-rackdc.properties
sed -i 's/$DESTINATION_RACK/$SOURCE_RACK/'  /etc/dse/cassandra/cassandra-rackdc.properties
sed -i 's/$SOURCE_DIRECTORY/$DESTINATION_DIRECTORY/'  /etc/dse/cassandra/cassandra.yaml
#----------------------------------------------------------------------------------------------#
service dse restart
cqlsh -e "SELECT key, cluster_name, data_center, rack from system.local;"
#----------------------------------------------------------------------------------------------#


#----------------------------------------------------------------------------------------------#
# Delete peers so Cassandra will not join the old cluster
#----------------------------------------------------------------------------------------------#
./3-delete-peers.sh


#----------------------------------------------------------------------------------------------#
# Upgrade System Tables
#----------------------------------------------------------------------------------------------#
cqlsh -e "UPDATE system.local set cluster_name = '$DESTINATION_CLUSTER' WHERE key ='local';"
cqlsh -e "UPDATE system.local set data_center='$DESTINATION_DC' WHERE key ='local';"
cqlsh -e "UPDATE system.local set rack = '$DESTINATION_RACK' WHERE key ='local';"
#----------------------------------------------------------------------------------------------#
cqlsh -e "SELECT key, cluster_name, data_center, rack from system.local;"

#----------------------------------------------------------------------------------------------#
# Flush new system settings 
#----------------------------------------------------------------------------------------------#
nodetool flush


#----------------------------------------------------------------------------------------------#
# Update settings with new Cassandra settings
#----------------------------------------------------------------------------------------------#
sed -i 's/$SOURCE_CLUSTER/$DESTINATION_CLUSTER/' /etc/dse/cassandra/cassandra.yaml
sed -i 's/$SOURCE_DC/$DESTINATION_DC/'  /etc/dse/cassandra/cassandra-rackdc.properties
sed -i 's/$SOURCE_RACK/$DESTINATION_RACK'  /etc/dse/cassandra/cassandra-rackdc.properties
#----------------------------------------------------------------------------------------------#
cqlsh -e "SELECT key, cluster_name, data_center, rack from system.local;"
#----------------------------------------------------------------------------------------------#
# Restart the DSE to verify that DSE cluster can succesfully start
#----------------------------------------------------------------------------------------------#
service dse restart
clear
tail -20f /var/log/cassandra/output.log
#----------------------------------------------------------------------------------------------#
