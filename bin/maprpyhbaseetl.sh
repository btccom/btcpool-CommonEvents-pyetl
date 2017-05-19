#!/bin/bash
# The destination of the data, values are maprdb, json, or parq
export DEST_TYPE="maprdb"

# Dealing with bad data
# Set to 1 to remove fields, starting left to right in the variable REMOVE_FIELDS to see if the json parsing works
export REMOVE_FIELDS_ON_FAIL=1

# If REMOVE_FIELDS_ON_FAIL is set to 1, and there is an error, the parser will remove the data from fields left to right, once json conversion works, it will break and move on (so not all fields may be removed)
export REMOVE_FIELDS="key1,key2"

# Turn on verbose logging.  For Silence export DEBUG=0
export DEBUG=1

# Kafka or MapR Stream config
# You must provide Bootstrap servers (kafka nodes and their ports OR Zookeepers and the kafka ID of the chroot for your kafka instance
#
# If using mapr streams comment out ZOOKEEPERS, and instead provide BOOTSTRAP_BROKERS="mapr" and the specify the topic in the MapR Format: i.e. TOPIC="/path/to/maprstreams:topicname"
# You must provide Bootstrap servers (kafka nodes and their ports OR Zookeepers and the kafka ID of the chroot for your kafka instance
#export ZOOKEEPERS=""
#export KAFKA_ID=""
# OR
export BOOTSTRAP_BROKERS="mapr"

# This is the name of the consumer group your client will create/join. If you are running multiple instances this is great, name them the same and Kafka will partition the info 
export GROUP_ID="some_groupid"

# When registering a consumer group, do you want to start at the first data in the queue (earliest) or the last (latest)
export OFFSET_RESET="earliest"

# The Topic to connect to
# the path to data is the HDFS path, not the mapr posix path. (i.e. not /mapr/cluster/path/to, just /path/to)
export TOPIC="/path/to/data/in/hdfs:topicname"

# This is the loop timeout, so that when this time is reached, it will cause the loop to occur (checking for older files etc)
export LOOP_TIMEOUT="5.0"

# The next three items has to do with the cacheing of records. As this come off the kafka queue, we store them in a list to keep from making smallish writes and dataframes
# These are very small/conservative, you should be able to increase, but we need to do testing at volume

export ROWMAX=1000 # Total max records cached. Regardless of size, once the number of records hits this number, the next record will cause a flush and write to parquet
export SIZEMAX=2560000000  # Total size of records. This is a rough running size of records in bytes. Once the total hits this size, the next record will cause a flush and write to parquet
export TIMEMAX=10  # seconds since last write to force a write # The number of seconds since the last flush. Once this has been met, the next record from KAfka will cause a flush and write. 

# MapR DB items
# This is where you want to write the maprdb table. This the HDFS (maprfs) path, not the posix path
export MAPRDB_TABLE_BASE="/path/to/mytable"

# Note another option is to use RANDOMROWKEYVAL to put a random number in the row key
# This is the field(s)  in your json you want to use as the hbase/maprdb row key If you want to concat fields, seperate by a comma and ensure your printed delim is correct
export MAPRDB_ROW_KEY_FIELDS='key1,key2,RANDOMROWKEYVAL' 

# This is the character, if you specified your fields as CSV above, that when we concat the fields, we put between them.  so if you have ip,ts as your row_key_fields, and use _ as your delim it may look like 123.123.123.123_2015-12-12 as your key
export MAPRDB_ROW_KEY_DELIM="_"

# For the columns in your data, which fields will be in which column families.
# Format: cf1:field1,cf1:field2,cf2:field3,cf4:field4
export MAPRDB_FAMILY_MAPPING='cf1:field1,cf1:field2,cf2:field3,cf4:field4"

# If the table does not exist, if this is set to 1, it will create it based on the column families. Otherwise it will exit (if not set to 1) - This could get ugly we don't set region size or permissions
export MAPRDB_CREATE_TABLE=0
# If batch inserts are enabled, set to 1
export MAPRDB_BATCH_ENABLED=1
# Print a drill view and exit
export MAPRDB_PRINT_DRILL_VIEW=0 


# Run Py ETL!
if [ "$DEST_TYPE" == "maprdb" ]; then
    # Mapr DB requires Python 2
    python -u /app/code/pyetl.py
else
    python3 -u /app/code/pyetl.py
fi
