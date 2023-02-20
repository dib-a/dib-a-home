#!/bin/bash

# Function to replace a line in a file
replace_line() {
  file=$1
  search_content=$2
  new_content=$3

  # Create a temporary file
  temp_file="$file.tmp"

  # Open the original file and read it line by line
  while read -r line; do
    if [ "$line" == "$search_content" ]; then
      # Replace the line with the new content
      echo "$new_content" >> "$temp_file"
    else
      # Write the original line to the temporary file
      echo "$line" >> "$temp_file"
    fi
  done < "$file"

  # Move the temporary file to the original file location
  mv "$temp_file" "$file"
}

# Update mirror-list
pacman-mirrors --geoip

# Config language
echo LANG=en_US.UTF-8 > /etc/locale.conf
replace_line '/etc/locale.gen' '#en_US.UTF-8 UTF-8' 'en_US.UTF-8 UTF-8'
replace_line '/etc/locale.gen' '#en_US ISO-8859-1' 'en_US ISO-8859-1'

locale-gen

# Setup system time
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc --utc

echo "Enter the hostname (computername)"
read hostname
echo $hostname > /etc/hostname

echo "Enter the root password (sudo password)"
passwd

echo "Enter the user name"
read username
useradd -mG wheel $username

echo "Enter the user password"
passwd $username

# Allow user in the wheel group to execute sudo
replace_line '/etc/sudoers' '# %wheel ALL=(ALL:ALL) ALL' '%wheel ALL=(ALL:ALL) ALL'

# Enable lan connection
systemctl enable dhcpcd

replace_line '/etc/mkinitcpio.conf' 'HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems fsck)' 'HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)'
mkinitcpio -P

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=manjaro --recheck

echo "Which type of disk do you use (SATA/M.2)"
read disk_type

# Check if the disk type is SATA or M.2
while true; do
    if [ "$disk_type" == "SATA" ]; then
        replace_line "/etc/default/grub" 'GRUB_CMDLINE_LINUX=""' 'GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda3:SYSTEM root=/dev/mapper/SYSTEM"'
        break
    elif [ "$disk_type" == "M.2" ]; then
        replace_line "/etc/default/grub" 'GRUB_CMDLINE_LINUX=""' 'GRUB_CMDLINE_LINUX="cryptdevice=/dev/nvme0n1p3:SYSTEM root=/dev/mapper/SYSTEM"'
        break
    else
        echo "Choose one of the options"
    fi
done

grub-mkconfig -o /boot/grub/grub.cfg

exit
