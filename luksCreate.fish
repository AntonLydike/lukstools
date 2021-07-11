# Copyright 2021 Anton Lydike
# Create a luks volume on a device
# Usage: luksCreate /dev/<device> <name>
# This will create a luks container containing an ext4 partition, encrypted 
# using a keyfile that is generated as ~/.keys/<name> (as expected by luksMount
# and luksClose).

function luksCreate --description "Create a luks volume on a device"
    set -l dev $argv[1]
    set -l name $argv[2]
    set -l key ~/.keys/$name

    if test -f $key
        echo "the key $name already exists! I won't override existing keys!"
        return 1
    end

    # generate key
    dd if=/dev/urandom of=$key bs=512 count=4
    or return 1
    chmod 400 $key

    # setup luks volume
    sudo cryptsetup luksFormat $dev $key
    or return 2
    sudo cryptsetup luksOpen --key-file=$key $dev $name
    or return 2

    # create pv and vg
    sudo pvcreate /dev/mapper/$name
    or return 3
    sudo vgcreate $name /dev/mapper/$name
    or return 3

    # create partition
    sudo lvcreate -l '100%FREE' -n data $name
    or return 4
    sudo mkfs.ext4 -L $name /dev/$name/data
    or return 4

    udisksctl mount -b /dev/$name/data
    or return 5
end
