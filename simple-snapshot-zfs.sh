#!/bin/bash

#v0.9
########################simple-snapshot-zfs#######################
###################### User Defined Options ######################
# List your ZFS datasets.  You can add/remove sets
# readarray -t DATASETS < <(zfs list -o name -H)  # when replacing DATASETS above, should return all pools/Datasets, not thoroughly tested yet.  If you test this let me know!
DATASETS=("workpool/admin" "workpool/archive")

# Set Number of Snapshots to Keep
SHANPSHOT_QTY=100

# Snapshot Name Format
SNAPSHOTNAME=$(date "+simplesnap_%Y-%m-%d-%H:%M:%S")

###### Don't change below unless you know what you're doing ######
##################################################################

echo "Starting Snapshot ${SNAPSHOTNAME}"
echo "_____________________________________________________________"

## Validation Steps
# Validate SHANPSHOT_QTY
if ! [[ $SHANPSHOT_QTY =~ ^[0-9]+$ ]]; then
  echo "Error: SHANPSHOT_QTY must be a positive integer."
  exit 1
fi

# Validate DATASETS
for dataset in "${DATASETS[@]}"; do
  if ! zfs list "$dataset" &>/dev/null; then
    echo "Error: Dataset '$dataset' does not exist."
    exit 1
  fi
done

# Function to handle errors
handle_error() {
  local error_message="$1"
  echo "Error: $error_message"
  exit 1
}

# Function to create snapshot if there is changed data
create_snapshot_if_changed() {
  local DATASET="$1"
  local WRITTEN
  WRITTEN=$(zfs get -H -o value written "${DATASET}")

  if [[ "${WRITTEN}" != "0" ]]; then
    if ! zfs snapshot "${DATASET}@${SNAPSHOTNAME}"; then
      handle_error "Failed to create snapshot for ${DATASET}"
    fi
    echo "Snapshot created: ${DATASET}@${SNAPSHOTNAME}"
  else
    echo "No changes detected in ${DATASET}. No snapshot created."
  fi
}

# Function to prune snapshots
prune_snapshots() {
  local DATASET="$1"
  local KEEP="${SHANPSHOT_QTY}"

  # Declare the SNAPSHOTS array
  declare -a SNAPSHOTS
  # Use mapfile to split the output into the SNAPSHOTS array
  if ! mapfile -t SNAPSHOTS < <(zfs list -t snapshot -o name -s creation -r "${DATASET}" | grep "^${DATASET}@"); then
    echo "Error: Failed to list snapshots for ${DATASET}"
    return 1
  fi

  local SNAPSHOTS_COUNT=${#SNAPSHOTS[@]}
  echo "Total snapshots for ${DATASET}: ${SNAPSHOTS_COUNT}"

  local SNAPSHOTS_SPACE
  if ! SNAPSHOTS_SPACE=$(zfs get -H -o value usedbysnapshots "${DATASET}"); then
    echo "Error: Failed to get space used by snapshots for ${DATASET}"
    return 1
  fi
  echo "Space used by snapshots for ${DATASET}: ${SNAPSHOTS_SPACE}"

  if [[ ${SNAPSHOTS_COUNT} -gt ${KEEP} ]]; then
    local TO_DELETE=$((SNAPSHOTS_COUNT - KEEP))
    for i in "${SNAPSHOTS[@]:0:${TO_DELETE}}"; do
      if ! zfs destroy "${i}"; then
        echo "Error: Failed to delete snapshot: ${i}"
        return 1
      fi
      echo "Deleted snapshot: ${i}"
      echo "_____________________________________________________________"
    done
  else
   echo "_____________________________________________________________"
  fi
}

# Iterate over each dataset and call the functions
for dataset in "${DATASETS[@]}"; do
  create_snapshot_if_changed "${dataset}"
  prune_snapshots "${dataset}"
done

echo "----------------------------Done!----------------------------"
