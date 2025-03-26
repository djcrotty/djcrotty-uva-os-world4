#!/bin/bash

KERNEL=$1

# Check if KERNEL is provided
if [ -z "$KERNEL" ]; then
  echo "Error: No kernel file provided. Please provide the kernel file as arg1."
  exit 1
fi

# Function to determine if running under WSL2
is_wsl2() {
  grep -qEi "microsoft|wsl" /proc/version &> /dev/null
}

# Function to check if a directory is an SD card partition
is_sd_card_partition() {
  local dir=$1
  lsblk -o MOUNTPOINT,TRAN --noheadings | grep -q "${dir}.*part"
}

# Function to probe BOOTFS_DIR under WSL2
probe_bootfs_dir() {
  for drv in {d..z}; do
    dir="/mnt/${drv}"
    if [ -d "$dir" ] && is_sd_card_partition "$dir" && [ -f "$dir/config.txt" ] && [ -f "$dir/$KERNEL" ]; then
      echo "$dir"
      return
    fi
  done
  echo ""
}

# Determine BOOTFS_DIR based on OS type
if is_wsl2; then
  while true; do
    BOOTFS_DIR=$(probe_bootfs_dir)
    if [ -n "$BOOTFS_DIR" ]; then
      break
    else
      echo "Unable to find BOOTFS_DIR. Retrying in 3 seconds..."
      sleep 3
    fi
  done
else
  BOOTFS_DIR="/media/$(whoami)/bootfs"
fi

# Copy the kernel file
if [ ! -d "$BOOTFS_DIR" ]; then
  echo "Error: BOOTFS_DIR does not exist: $BOOTFS_DIR"
  exit 1
fi

if [ ! -f "$BOOTFS_DIR/$KERNEL" ]; then
  echo "Warning: $KERNEL does not exist in BOOTFS_DIR: $BOOTFS_DIR"
  read -p "Do you want to continue copying? (y/N): " response
  case "$response" in
    [yY][eE][sS]|[yY])
      ;;
    *)
      echo "Aborted."
      exit 1
      ;;
  esac
fi

cp "$KERNEL" "$BOOTFS_DIR"
if [ $? -eq 0 ]; then
  echo "Kernel file successfully copied to $BOOTFS_DIR."
else
  echo "Error: Failed to copy kernel file to $BOOTFS_DIR."
  exit 1
fi
