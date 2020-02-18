#!/usr/bin/env python3

from pymongo import MongoClient, errors

mongosClient = MongoClient('mongos', serverSelectionTimeoutMS=2000)

configClients = [
    MongoClient('mongo1-c', serverSelectionTimeoutMS=2000),
    MongoClient('mongo2-c', serverSelectionTimeoutMS=2000),
    MongoClient('mongo3-c', serverSelectionTimeoutMS=2000)]

replicaSet1Clients = [
    MongoClient('mongo1-r1', serverSelectionTimeoutMS=2000),
    MongoClient('mongo2-r1', serverSelectionTimeoutMS=2000),
    MongoClient('mongo3-r1', serverSelectionTimeoutMS=2000)]

replicaSet2Clients = [
    MongoClient('mongo1-r2', serverSelectionTimeoutMS=2000),
    MongoClient('mongo2-r2', serverSelectionTimeoutMS=2000),
    MongoClient('mongo3-r2', serverSelectionTimeoutMS=2000)]

def test_connection(clientsList):
    for c in clientsList:
        while True:
            try:
                print('Address: {0}:{1}'.format(*c.address))
                print('Server ok: {}'.format(c.server_info().get('ok')))
                break
            except errors.ServerSelectionTimeoutError as err:
                print(err)
        c.close()

def test_replicaset(rsName, clientList):
    connList = []
    for c in clientList:
        connList.append("{}:{}".format(*c.address))
    testClient = MongoClient(connList, replicaset=rsName)
    while True:
        try:
            print('Replica set: {}'.format(rsName))
            print('ok: {}'.format(testClient.admin.command('replSetGetStatus').get('ok')))
            break
        except: 
            print('Can\'t verify replica set: {}'.format(rsName)) 
    testClient.close()

def test_mongos(mongos):
    while True:
        try:
            print('Address: {0}:{1}'.format(*mongos.address))
            print('Server ok: {}'.format(mongos.server_info().get('ok')))
            break
        except errors.ServerSelectionTimeoutError as err:
            print('Waiting for MongoS to start.')
            print(err)
    mongos.close()


def init_replicaset(rsName, clinetsList):
    config = {'_id': rsName, 'members': []}
    id = 0
    for c in clinetsList:
        member = {'_id': id, 'host': '{}:{}'.format(*c.address)}
        config['members'].append(member)
        id = id +1
    try:
        clinetsList[0].admin.command("replSetInitiate", config)
        print("Successfully initiated {}.".format(rsName))
    except:
        pass
    finally:
        clinetsList[0].close()

def init_shard(rsName, mongos, clientsList):
    connStr = "{}/".format(rsName)
    for c in clientsList:
        connStr += "{}:{},".format(*c.address)
    connStr = connStr[:-1]  # Deletes the last colon
    if mongos.is_mongos:
        mongos.admin.command('addShard', connStr)
        print("{} added to shard.".format(rsName))
    else:
        print('Target host is not MongoS, shards not initiated.')
    mongos.close()

print('''
####################################
TESTING CONNECTIONS
####################################
''')
test_connection(configClients) 
test_connection(replicaSet1Clients) 
test_connection(replicaSet2Clients) 

print('''
####################################
INIT REPLICA SETS
####################################
''')
init_replicaset('rConf',configClients)
init_replicaset('r1',replicaSet1Clients)
init_replicaset('r2',replicaSet2Clients)

print('''
####################################
INIT REPLICA SETS
####################################
''')
test_mongos(mongosClient)

print('''
####################################
TEST REPLICA SETS CREATION
####################################
''')
test_replicaset('rConf', configClients)
test_replicaset('r1', replicaSet1Clients)
test_replicaset('r2', replicaSet2Clients)

print('''
####################################
INIT SHARDS
####################################
''')
init_shard('r1', mongosClient, replicaSet1Clients)
init_shard('r2', mongosClient, replicaSet2Clients)


