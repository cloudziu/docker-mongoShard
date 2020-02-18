#!/bin/bash

## ConfigSrv ReplicaSet
# wait for mongo to startup
until echo "db.adminCommand('ping')" | mongo --host mongo1-c --quiet; do echo "Waiting for Mongo RS-Conf SRV-1 to start"; sleep 2; done;
echo "### MONGO RS-Conf SRV-1 IS UP ###"
until echo "db.adminCommand('ping')" | mongo --host mongo2-c --quiet; do echo "Waiting for Mongo RS-Conf SRV-2 to start"; sleep 2; done;
echo "### MONGO RS-Conf SRV-2 IS UP ###"
until echo "db.adminCommand('ping')" | mongo --host mongo3-c --quiet; do echo "Waiting for Mongo RS-Conf SRV-3 to start"; sleep 2; done;
echo "### MONGO RS-Conf SRV-3 IS UP ###"
# Init RS-Conf
echo "### INITIALIZATING REPLICASET-CONF ###"
echo "rs.initiate({ _id: \"rConf\", members:[{_id: 0, host: \"mongo1-c:27017\"},{_id: 1, host: \"mongo2-c:27017\"},{_id: 2, host: \"mongo3-c:27017\"},]})" | mongo --host mongo1-c



## ReplicaSet-1
# wait for mongo to startup
until echo "db.adminCommand('ping')" | mongo --host mongo1-r1 --quiet; do echo "Waiting for Mongo RS-1 SRV-1 to start"; sleep 2; done;
echo "### MONGO RS-1 SRV-1 IS UP ###"
until echo "db.adminCommand('ping')" | mongo --host mongo2-r1 --quiet; do echo "Waiting for Mongo RS-1 SRV-2 to start"; sleep 2; done;
echo "### MONGO RS-1 SRV-2 IS UP ###"
until echo "db.adminCommand('ping')" | mongo --host mongo3-r1 --quiet; do echo "Waiting for Mongo RS-1 SRV-3 to start"; sleep 2; done;
echo "### MONGO RS-1 SRV-3 IS UP ###"
# Init RS-1
echo "### INITIALIZATING REPLICASET-1 ###"
echo "rs.initiate({ _id: \"r1\", members:[{_id: 0, host: \"mongo1-r1:27017\"},{_id: 1, host: \"mongo2-r1:27017\"},{_id: 2, host: \"mongo3-r1:27017\"},]})" | mongo --host mongo1-r1



## ReplicaSet-2
# wait for mongo to startup
until echo "db.adminCommand('ping')" | mongo --host mongo1-r2 --quiet; do echo "Waiting for Mongo RS-2 SRV-1 to start"; sleep 2; done;
echo "### MONGO RS-2 SRV-1 IS UP ###"
until echo "db.adminCommand('ping')" | mongo --host mongo2-r2 --quiet; do echo "Waiting for Mongo RS-2 SRV-2 to start"; sleep 2; done;
echo "### MONGO RS-2 SRV-2 IS UP ###"
until echo "db.adminCommand('ping')" | mongo --host mongo3-r2 --quiet; do echo "Waiting for Mongo RS-2 SRV-3 to start"; sleep 2; done;
echo "### MONGO RS-2 SRV-3 IS UP ###"
# Init RS-2
echo "### INITIALIZATING REPLICASET-2 ###"
echo "rs.initiate({ _id: \"r2\", members:[{_id: 0, host: \"mongo1-r2:27017\"},{_id: 1, host: \"mongo2-r2:27017\"},{_id: 2, host: \"mongo3-r2:27017\"},]})" | mongo --host mongo1-r2



## MongoS Router
# wait for mongos to star
until echo "db.adminCommand('ping')" | mongo --host mongos; do echo "Waiting for MongoS ROUTER to start"; sleep 2; done;
echo "### MONGO ROUTER IS UP ###"
# wait for R1 and R2 replica sets
while [ $(echo "rs.status().ok" | mongo --host mongo1-r1 --quiet) -eq 0 ]; do echo "Waiting for R1 Replica Set"; sleep 2; done
echo "R1 Replica Set is ready to use by MongoS"
while [ $(echo "rs.status().ok" | mongo --host mongo1-r2 --quiet) -eq 0 ]; do echo "Waiting for R2 Replica Set"; sleep 2; done
echo "R2 Replica Set is ready to use by MongoS"
# Add shards cluster to mongoS
echo "sh.addShard(\"r1/mongo1-r1:27017,mongo2-r1:27017,mongo3-r1:27017\")" | mongo --host mongos
echo "sh.addShard(\"r2/mongo1-r2:27017,mongo2-r2:27017,mongo3-r2:27017\")" | mongo --host mongos
echo "Shards added to mongoS"


