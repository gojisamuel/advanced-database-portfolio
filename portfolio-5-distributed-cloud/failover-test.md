# Failover test (collect screenshots)
1. `./init-replica.sh` -> one PRIMARY, two SECONDARY.
2. Write: `docker compose exec mongo1 mongosh --eval 'db.getSiblingDB("paywise_nosql").t.insertOne({x:1},{writeConcern:{w:"majority"}})'`
3. Kill the primary: `docker compose stop mongo1`
4. After ~10-15 s check: `docker compose exec mongo2 mongosh --eval 'rs.status().members.forEach(m=>print(m.name,m.stateStr))'` -> a new PRIMARY is elected.
5. Read the earlier document from the new primary (data survived).
6. `docker compose start mongo1` -> it rejoins as SECONDARY.
