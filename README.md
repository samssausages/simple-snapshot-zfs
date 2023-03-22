# simple-snapshot-zfs #

This is a simple script to create ZFS Snapshots, designed to overcome snapshots with 0 changes cluttering your snapshot list.
To run, simply add script as a cron job.

## Key features: ##

* Runs a check to see if the dataset has been written to before snapshot
* Prunes snapshots by keeping only the most recent 100 (adjustable)
* Provides output to let you know how many snaps and how much space is taken up

## Usage ##

Update script with your dataset names, including the pool.  Don't add a leading `/`, should look like: `pool/dataset1`

Run script manually or add it to a cron shedule

### Sample output ###

```
Starting Snapshot 20230321-2349
_______________________________________
No changes detected in pool/admin. No snapshot created.
Total snapshots for pool/admin: 1
Space used by snapshots for pool/admin: 0B
_______________________________________
Snapshot created: pool/admin/code@20230321-2349
Total snapshots for pool/admin/code: 6
Space used by snapshots for pool/admin/code: 8.06M
_______________________________________
No changes detected in pool/admin/certs. No snapshot created.
Total snapshots for pool/admin/certs: 3
Space used by snapshots for pool/admin/certs: 947K
_______________________________________
No changes detected in pool/documents. No snapshot created.
Total snapshots for pool/documents: 4
Space used by snapshots for pool/documents: 17.5G
_______________________________________
No changes detected in pool/documents/nextcloud. No snapshot created.
Total snapshots for pool/documents/nextcloud: 2
Space used by snapshots for pool/documents/nextcloud: 20.0G
_______________________________________
-----------------Done!-----------------

```
