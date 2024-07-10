#!/bin/bash
# Pre-install script for dynamic autoinstall.yaml generation

# Determine the smallest disk for installation
smallest_disk=$(lsblk -b -d -o NAME,SIZE | sort -k2 -n | head -n 1 | awk '{print $1}')

# Download the base autoinstall.yaml template
curl -o /tmp/autoinstall_template.yaml http://example.com/autoinstall_template.yaml

# Generate the storage configuration dynamically
cat <<EOSTORAGE >> /tmp/autoinstall_template.yaml
storage:
  config:
    - id: disk0
      type: disk
      match:
        path: /dev/${smallest_disk}
      ptable: gpt
      wipe: superblock-recursive
      grub_device: true
    - id: disk0-boot-efi
      type: partition
      size: 512M
      device: disk0
      flag: boot
    - id: disk0-boot-efi-fs
      type: format
      fstype: fat32
      volume: disk0-boot-efi
      label: EFI
    - id: disk0-boot
      type: partition
      size: 1G
      device: disk0
    - id: disk0-boot-fs
      type: format
      fstype: ext4
      volume: disk0-boot
      label: boot
    - id: disk0-pv
      type: partition
      size: -1
      device: disk0
    - id: disk0-pv-lvm
      type: lvm_physical_volume
      volume: disk0-pv
    - id: disk0-vg
      type: lvm_volume_group
      name: vg0
      devices:
        - disk0-pv-lvm
    - id: thin-pool
      type: lvm_thin_pool
      name: thinpool
      size: 180G  # Adjusted to accommodate all thin volumes
      volume_group: vg0
    - id: root-lv
      type: lvm_thin_volume
      name: root
      size: 30G
      pool: thinpool
    - id: root-lv-fs
      type: format
      fstype: ext4
      volume: root-lv
      label: root
    - id: var-lv
      type: lvm_thin_volume
      name: var
      size: 20G
      pool: thinpool
    - id: var-lv-fs
      type: format
      fstype: ext4
      volume: var-lv
      label: var
    - id: var-log-lv
      type: lvm_thin_volume
      name: var-log
      size: 10G
      pool: thinpool
    - id: var-log-lv-fs
      type: format
      fstype: ext4
      volume: var-log-lv
      label: var-log
    - id: var-log-audit-lv
      type: lvm_thin_volume
      name: var-log-audit
      size: 5G
      pool: thinpool
    - id: var-log-audit-lv-fs
      type: format
      fstype: ext4
      volume: var-log-audit-lv
      label: var-log-audit
    - id: var-tmp-lv
      type: lvm_thin_volume
      name: var-tmp
      size: 5G
      pool: thinpool
    - id: var-tmp-lv-fs
      type: format
      fstype: ext4
      volume: var-tmp-lv
      label: var-tmp
    - id: tmp-lv
      type: lvm_thin_volume
      name: tmp
      size: 10G
      pool: thinpool
    - id: tmp-lv-fs
      type: format
      fstype: ext4
      volume: tmp-lv
      label: tmp
    - id: swap
      type: partition
      size: 4G
      device: disk0
    - id: swap-fs
      type: format
      fstype: swap
      volume: swap
    - id: home-lv
      type: lvm_thin_volume
      name: home
      size: 120G  # Adjusted for larger /home partition
      pool: thinpool
    - id: home-lv-fs
      type: format
      fstype: ext4
      volume: home-lv
      label: home
EOSTORAGE

# Replace the original autoinstall.yaml with the generated one
mv /tmp/autoinstall_template.yaml /autoinstall.yaml
