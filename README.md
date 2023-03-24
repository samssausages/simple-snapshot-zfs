# simple-snapshot-zfs

This is a simple script to create ZFS Snapshots, designed to overcome snapshots with 0 changes cluttering your snapshot list.
To run, simply add script as a cron job.

It has been pointed out that this can complicate restores with some 3rd party programs that use multiple snapshot policies.  So use this only if it suits your snapshot/rollback strategy.  
In my case, I only have a few datasets that I self-manage.  So it works well for me as I want to avoid the visual clutter and don't rely on 3rd party systems for snapshots or restores.

## Key features

* Runs a check to see if the dataset has been written to before snapshot
* Prunes snapshots by keeping only the most recent 100 (adjustable)
* Provides output to let you know how many snaps and how much space is taken up

## Usage

Update script with your dataset names, including the pool.  Don't add a leading `/`, should look like: `pool/dataset1`

Run script manually or add it to a cron shedule

### Sample output

```
Starting Snapshot 2023-03-23-23:21
_____________________________________________________________
No changes detected in pool/dataset1. No snapshot created.
Total snapshots for pool/admin: 3
Space used by snapshots for pool/dataset1: 239K
_____________________________________________________________
Snapshot created: pool/dataset1/code@2023-03-23-23:21
Total snapshots for pool/admin/code: 20
Space used by snapshots for pool/dataset1/code: 18.0M
_____________________________________________________________
No changes detected in pool/dataset2. No snapshot created.
Total snapshots for pool/admin/certs: 3
Space used by snapshots for pool/dataset2: 947K
_____________________________________________________________
No changes detected in pool/documents. No snapshot created.
Total snapshots for pool/documents: 5
Space used by snapshots for pool/documents: 17.5G
_____________________________________________________________
No changes detected in pool/documents/nextcloud. No snapshot created.
Total snapshots for pool/documents/nextcloud: 4
Space used by snapshots for pool/documents/nextcloud: 20.0G
_____________________________________________________________
----------------------------Done!----------------------------

```


# Changelog

v0.15 
Address coding standards & issues
Define user configurable section, formatting
Updated Timestamp Formatting for readability

v0.10
Initial Commit