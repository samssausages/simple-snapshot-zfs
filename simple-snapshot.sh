#!/bin/bash

# List your ZFS datasets
DATASETS=("pool/dataset1" "pool/dataset2" "pool/dataset3" "pool/dataset4" "pool/dataset5")

echo "Starting Snapshot $(date "+%Y%m%d-%H%M")"
echo "_______________________________________" 

# Function to create snapshot if there is changed data
create_snapshot_if_changed() {
  local DATASET="$1"
  local WRITTEN=$(zfs get -H -o value written "${DATASET}")

  if [ "${WRITTEN}" != "0" ]; then
    local TIMESTAMP=$(date "+%Y%m%d-%H%M")
    zfs snapshot "${DATASET}@${TIMESTAMP}"
    echo "Snapshot created: ${DATASET}@${TIMESTAMP}"
  else
    echo "No changes detected in ${DATASET}. No snapshot created."
  fi
}

# Function to prune snapshots
prune_snapshots() {
  local DATASET="$1"
  local KEEP=100

  local SNAPSHOTS=( $(zfs list -t snapshot -o name -s creation -r "${DATASET}" | grep "^${DATASET}@") )
  local SNAPSHOTS_COUNT=${#SNAPSHOTS[@]}

  echo "Total snapshots for ${DATASET}: ${SNAPSHOTS_COUNT}"

  local SNAPSHOTS_SPACE=$(zfs get -H -o value usedbysnapshots "${DATASET}")
  echo "Space used by snapshots for ${DATASET}: ${SNAPSHOTS_SPACE}"

  if [ ${SNAPSHOTS_COUNT} -gt ${KEEP} ]; then
    local TO_DELETE=$((SNAPSHOTS_COUNT - KEEP))
    for i in "${SNAPSHOTS[@]:0:${TO_DELETE}}"; do
      zfs destroy "${i}"
      echo "Deleted snapshot: ${i}"
      echo "_______________________________________"    
    done
  else
    echo "_______________________________________"  
  fi
}

# Iterate over each dataset and call the functions
for dataset in "${DATASETS[@]}"; do
  create_snapshot_if_changed "${dataset}"
  prune_snapshots "${dataset}"
done

echo "-----------------Done!-----------------"
