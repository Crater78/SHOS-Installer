![Header](./github-header-banner.png)
SHOS is a small, bootable installer for Home Assistant on generic x86_64 hardware, designed to be easy to flash and simple to use. It installs the full Home Assistant Operating System (HAOS) directly onto your machine, giving you the standard, fully supported OS configuration recommended for x86_64 systems. Once installation is complete, the result behaves like a normal HAOS install, with official update support, add-ons, and long-term maintenance handled through Home Assistant’s built-in tools.# Flashing SHOS
# Flashing SHOS to a USB
## Prerequisites
- A Windows or Linux computer
- A USB drive with at least 1 GB of storage
- balenaEtcher

## Flashing from Windows
1. If you do not have balenaEtcher installed, download and install it from the [official site](https://etcher.balena.io/#download-etcher).
2. Download the latest SHOS ISO from the [releases page](https://github.com/Crater78/SHOS-Installer/releases).
3. Use balenaEtcher to flash the ISO file to your USB drive.
4. Wait for the flashing **and** verification process to complete.
5. Safely eject your USB drive.

## Flashing from Linux
1. Plug in your USB drive.  
2. Open a terminal.  
3. Run `lsblk` and identify your USB device path (for example, `/dev/sdb`, **not** a partition like `/dev/sdb1`).  
4. Ensure the USB device is not mounted (unmount any `/dev/sdX*` partitions if needed, replacing `X` with the correct letter).  
5. Download the latest SHOS ISO from the [releases page](https://github.com/Crater78/SHOS-Installer/releases).  
6. Run this command, replacing `/path/to/file.iso` with the ISO you downloaded and `/dev/sdX` with your USB device path:  
   `sudo dd bs=4M if=/path/to/file.iso of=/dev/sdX status=progress oflag=sync`  
7. Wait for it to finish flashing and syncing. The command exits when complete.  
8. Run `sync` once more to ensure all data is written, then safely remove your USB drive.

---

# Flashing HAOS from SHOS

## Prerequisites
- An x86_64 computer with a working network connection
- A USB drive containing SHOS
- A keyboard and display

## Guide
1. Boot into your computer’s BIOS.  
2. Enable UEFI, but **disable Secure Boot**.  
3. Shut down the computer and insert the SHOS USB drive.  
4. Power on and open the boot menu (usually by pressing `F12` or `F2`).  
5. Select the USB drive from the boot options.  
6. When the boot menu loads, press **Enter** to continue.  
7. Once SHOS has booted, select **Install Home Assistant** and follow the on-screen instructions.  
   - A working network connection is required.  
   - Installation may take up to 30 minutes.

---

# Building SHOS

## Prerequisites
- Debian 13
- At least 5 GB of free space
- The latest version of `live-build`

## Guide
1. Clone the repository:  
   `gh repo clone Crater78/SHOS-Installer`  
2. Navigate into the SHOS directory:  
   `cd SHOS-Installer`  
3. Run the build script:  
   `sudo bash build.sh`  
4. Wait for the process to complete (typically 3–5 minutes depending on system performance).

That’s it! The output of the build script will be located in the `tmp` folder.
