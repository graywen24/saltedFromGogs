# Icinga2 - install, configure, update

## State tree structure

  * states files
  * execution modules
  * state modules
  * reactor
  * runner
  * pillar

## System Components
  * cluster/zones/nodes
  * configuration states

## Architecture
All environments are 2 or 3 level setups. The CDE will contain the top master servers, which receive all check results. Each Alchemy Exclusive has three satellites, which will collect the check results from all nodes in that environment and forward them to the masters.

## Cluster configuration
  * Zone setup
  * Common configuration elements
  * CA and certificates

## Update a node
If you update checks on a node these changes are automatically synced to the collecting satellite for that node - this is done by the cluster feature of icinga2. The state to update the node will trigger an event send to the master, which will take care of updating the satellite configuration and forwarding it to the top masters.

  Flow
  * run the icinga.instance.host/master/satellite state to update the nodes configuration
  * this state triggers the icinga2/cluster/update event
  * the icinga2 reactor will handle this event and call the icinga2 runner
  * the runner fires the states needed, which will bubble up the event if needed
  * if the parent has a parent it will also trigger the event for that

