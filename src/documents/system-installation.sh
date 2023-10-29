#!/bin/bash

# Choose a disk
lsblk
echo "Which disk do you want to format and use for partitioning? (Do not forget to start with /dev/)"
read disk

# Check if disk is SATA or M.2
if [[ $disk == *"sd"* ]]; then
  partition_prefix=""
else
  partition_prefix="p"
fi

# Check if the selected disk is available
if [ ! -b $disk ]; then
  echo "The selected disk is not available."
  exit 1
fi

# Ask the user if they are sure they want to wipe the disk
echo "Are you sure you want to wipe everything from $disk?"
read -p "This action cannot be undone. (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Exiting script."
  exit 0
fi

# Wipe everything from the disk
wipefs -a $disk

# Create EFI partition
parted $disk mklabel gpt
parted $disk mkpart primary fat32 0% 301MiB
parted $disk set 1 boot on
mkfs.fat -F32 -n EFI ${disk}${partition_prefix}1

# Create BOOT partition
parted $disk mkpart primary ext4 301MiB 601MiB
mkfs.ext4 -L BOOT ${disk}${partition_prefix}2

# Create encrypted SYSTEM partition
parted $disk mkpart primary ext4 601MiB 100%

# Loop until the LUKS encryption is set correctly
while true; do
  echo "Enter a passphrase for the LUKS encryption:"
  cryptsetup luksFormat ${disk}${partition_prefix}3

  if [ $? -eq 0 ]; then
    break
  else
    echo "Failed to set LUKS encryption, try again."
  fi
done

# Open the encrypted SYSTEM partition
cryptsetup open ${disk}${partition_prefix}3 SYSTEM

# Format the encrypted SYSTEM partition with ext4
mkfs.ext4 /dev/mapper/SYSTEM -L SYSTEM

# Mount SYSTEM partition
mount -L SYSTEM /mnt

# Mount BOOT partition
mkdir /mnt/boot
mount -L BOOT /mnt/boot

# Mount EFI partition
mkdir /mnt/boot/efi
mount -L EFI /mnt/boot/efi

# Install base system
basestrap /mnt base base-devel linux65 linux-firmware dhcpcd grub mkinitcpio efibootmgr git neovim sudo

# Generate fstab
fstabgen -U /mnt > /mnt/etc/fstab

# Change to new system
manjaro-chroot /mnt

# Umount everything
umount -R /mnt
cryptsetup close SYSTEM
