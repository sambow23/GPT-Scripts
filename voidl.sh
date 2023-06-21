import os
import requests
import tarfile
import subprocess
import psutil
from tqdm import tqdm

IMAGE_URL = "https://repo-default.voidlinux.org/live/current/void-live-x86_64-musl-20221001-xfce.iso"

def download_file(url):
    local_filename = url.split('/')[-1]
    if os.path.exists(local_filename):
        print(f"File {local_filename} already exists, skipping download.")
        return local_filename

    response = requests.get(url, stream=True)
    total = int(response.headers.get('content-length', 0))
    
    with open(local_filename, 'wb') as f, tqdm(
            desc=local_filename,
            total=total,
            unit='iB',
            unit_scale=True,
            unit_divisor=1024,
        ) as bar:
        for data in response.iter_content(chunk_size=1024):
            size = f.write(data)
            bar.update(size)
    return local_filename

def extract_to_drive(file_path, destination_drive):
    with tarfile.open(file_path) as tf:
        tf.extractall(path=destination_drive)

def install_grub(destination_drive):
    subprocess.run(["grub-install", "--root-directory=/mnt", destination_drive], check=True)

def list_drives():
    result = subprocess.run(["lsblk", "-dpnlo", "NAME"], stdout=subprocess.PIPE, text=True)
    drives = result.stdout.splitlines()
    for i, drive in enumerate(drives):
        print(f"{i+1}. {drive}")
    return drives

def select_drive(drives):
    while True:
        choice = input("Select the drive number where you want to install the Linux distribution: ")
        if choice.isdigit() and 1 <= int(choice) <= len(drives):
            return drives[int(choice) - 1]
        else:
            print("Invalid choice. Please enter a number from the list.")

# Main script
def main():
    print("Downloading Void Linux XFCE musl live image...")
    image_path = download_file(IMAGE_URL)

    print("Available drives:")
    drives = list_drives()
    destination_drive = select_drive(drives)
    
    print(f"Extracting image to {destination_drive}...")
    extract_to_drive(image_path, destination_drive)
    
    print("Installing GRUB...")
    install_grub(destination_drive)

    print("Done!")

if __name__ == "__main__":
    main()

