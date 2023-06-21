#!/usr/bin/env python3

import os
import subprocess
import requests

# Constants
IMAGE_URL = "https://repo-default.voidlinux.org/live/current/void-live-x86_64-musl-20221001-xfce.iso"
IMAGE_NAME = "void-live-x86_64-musl-20221001-xfce.iso"
MOUNT_POINT_ISO = "/mnt/iso"
MOUNT_POINT_TARGET = "/mnt/target"

# Check if the image is already downloaded
def check_existing_image():
    return os.path.isfile(IMAGE_NAME)

# Download the Void Linux ISO
def download_image():
    print("Downloading Void Linux ISO...")
    response = requests.get(IMAGE_URL, stream=True)
    response.raise_for_status()
    with open(IMAGE_NAME, 'wb') as fd:
        for chunk in response.iter_content(chunk_size=1024*1024):
            fd.write(chunk)
    print("Download completed.")

# Mount the ISO
def mount_iso():
    os.makedirs(MOUNT_POINT_ISO, exist_ok=True)
    subprocess.run(["mount", "-o", "loop", IMAGE_NAME, MOUNT_POINT_ISO], check=True)

# Unmount the ISO
def unmount_iso():
    subprocess.run(["umount", MOUNT_POINT_ISO], check=True)

# Copy contents of the ISO to the target drive
def copy_to_drive(destination_drive):
    print(f"Copying contents to {destination_drive}...")
    subprocess.run(["cp", "-a", MOUNT_POINT_ISO + "/*", destination_drive], check=True)
    print(f"Copying completed to {destination_drive}.")

# Install GRUB and make the drive bootable
def install_grub(destination_drive):
    print("Making the drive bootable...")
    os.makedirs(MOUNT_POINT_TARGET, exist_ok=True)
    subprocess.run(["mount", destination_drive + "1", MOUNT_POINT_TARGET], check=True)
    subprocess.run(["chroot", MOUNT_POINT_TARGET], check=True)
    subprocess.run(["grub-install", destination_drive], check=True)
    subprocess.run(["update-grub"], check=True)
    subprocess.run(["exit"], check=True)
    subprocess.run(["umount", MOUNT_POINT_TARGET], check=True)
    print("The drive is now bootable.")

def main():
    # Check if the image is already downloaded
    if not check_existing_image():
        download_image()

    # Prompt the user to enter the destination drive
    destination_drive = input("Please enter the destination drive (e.g., /dev/sdX): ")
    
    # Mount the ISO, copy its contents to the target drive, make it bootable, and unmount the ISO
    mount_iso()
    copy_to_drive(destination_drive)
    install_grub(destination_drive)
    unmount_iso()

if __name__ == "__main__":
    main()

