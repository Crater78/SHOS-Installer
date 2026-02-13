#!/bin/sh
set -e

# Attempt to quiet down IO
sync
umount -f /run/live/medium 2>/dev/null || true
umount -f /lib/live/mount/medium 2>/dev/null || true
umount -f /cdrom 2>/dev/null || true

echo "HAOS has been installed."
echo "Please remove the installation media now."
echo "Then press Enter to reboot."
echo

# Wait to confirm removal
read _

exit 0