#!/bin/bash

# Wait for config replica set
while [ $(echo "rs.status().ok" | mongo --host mongo1-c --quiet) -eq 0 ]; do echo "Waiting for Config Replica Set"; sleep 2; done
echo "Config Replica Set is ready to use by MongoS"

mongos --configdb rConf/mongo1-c:27017,mongo2-c:27017,mongo3-c:27017 --bind_ip 0.0.0.0
