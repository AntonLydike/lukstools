# Copyright 2021 Anton Lydike
# Mount a luks device, should work with most luks setups as it tries to identify
# the name of the logical volume using lvm
# Usage: luksMount /dev/<device> <name>
# This will open the luks container using the key in ~/.keys/<name> and mount
# the logical volume inside it.

function luksMount --description "Open and Mount a luks container"
    set -l disk $argv[1]
    set -l key $argv[2]
    set -l name (basename $key)

    sudo cryptsetup luksOpen --key-file=$key $disk $name
    or return 1

    set -l dev (string trim (sudo lvm -C -o "lv_path" /dev/mapper/$name)[2])
    udisksctl mount -b $dev 
    or return 2
end
