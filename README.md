Cassandra Data Directory Backup/Restore
=======================================

* 0-backup-cassandra.sh - Copy Cassandra raw direrectory with files into desctination using rsync
* 1-downgrade-dse.sh - Downgrade Cassandra to the source version 4.8.4 
  * ls -l /user/share/dse
* 2-update-system.sh - Update Cassandra yaml files and system tables
* 3-delete-peers.sh - Delete peers

### Bash Aliases 

```
$ vi ~/.bash_aliases
  alias 1='tail -50f /var/log/cassandra/output.log'
  alias 2='tail -50f /var/log/cassandra/system.log'
```

