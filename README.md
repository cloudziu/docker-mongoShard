# Introduction
This docker-compose file creates a sharded mongodb cluster with two replicaSets ( RS ) in it, config RS, mongos as a router and one job container whitch is responible for inicialization. Each RS contains three mongod nodes. The processes of linking mongo nodes into RS, and then shards is maintained by the ~~bash job~~ python-job container, which will automaticly shutdown after performing its tasks.

```
   +--------------------------------+
   |                                |
   |                                |
   |          Shard 1       Shard 2 |
   |       +----------+   +---------v+
   |       |          |   |          |
   |       |          |   |          |
   |       |          |   |          |
   |       |          |   |          |
   |  +---->          |   |          |
   |  |    +-----^----+   +----^-----+      Config RS
   |  |          |             |           +----------+
   |  |          |             |           |          |
   |  |          |             |           |          |
   |  |          |             |           |          |
   |  |          +----+    +---+           |          |
   |  |               |    |               |          |
   |  |              ++----++              +----^---^-+
+--+--++             |      |                   |   |
|      +------------->      +-------------------+   |
|      |             |      |                       |
|      |             +------+                       |
+-----++              mongos                        |
 P-JOB|                                             |
      +---------------------------------------------+

```

# Usage

Change the current working directory to the project folder, so the **ls** output will show:
```bash
> ls -1a                                                                                
.
..
docker-compose.yml
.env
job
mongos
mongosfile
README.md

```

To set the port on withch the cluster will be accessible on localhost, edit the **MONGOS_PORT** value in **.env** file.
```bash
> cat .env
MONGOS_PORT=27017
> echo "MONGOS_PORT=<your_port>" > .env
> cat .env
MONGOS_PORT=<your_port>
```
Whlie beeing in the project directory, start the cluster with docker-compose.
```bash
> docker-compose up
```

## Example - creating sharded database and collection
Connect to the cluster with *mongo* shell.
```bash
mongo --host localhost --port 27017 (or another port specyfied in .env file)
```
Enable sharding for database
```bash
mongos> sh.enableShrading("test")
```
To start sharding collection
```bash
mongos> sh.shardCollection("test.grades", {student_id : 1})
```

## Deleting / Troubleshooting
To delete the cluster, without deleting the volumes:
```bash
>docker-compose down
```
To delete the cluster **and** the volumes use
```bash
>docker-compose down -v
```
To edit the init scripts, there is a need to tell docker-compose to rebuild images after making changes in it.
```bash
>docker-compose up --build
```
