#!/bin/bash
# Run after: docker compose up -d
docker compose exec mongo1 mongosh --eval '
rs.initiate({_id:"rs0", members:[
  {_id:0, host:"mongo1:27017", priority:2},
  {_id:1, host:"mongo2:27017"},
  {_id:2, host:"mongo3:27017"}]});
'
sleep 10
docker compose exec mongo1 mongosh --eval 'rs.status().members.forEach(m => print(m.name, m.stateStr))'
