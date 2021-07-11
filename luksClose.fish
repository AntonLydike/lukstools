# Copyright 2021 Anton Lydike
# Close a mounted luks container
# Usage: luksClose <name>
# This will unmount the partition, close the logical volume and luks container.

function luksClose --description "Unmount and close an opened luks container"
    set -l name $argv[1]

    # unmount volume
    udisksctl unmount -b (string trim (sudo lvm -C -o "lv_path" /dev/mapper/$name)[2])
    or return 1
    
    sudo vgchange -a n (string trim (sudo lvm -C -o "vg_name" /dev/mapper/$name)[2])
    or return 2
    
    sudo cryptsetup luksClose /dev/mapper/$name
    or return 3
    
    set_color green
    echo "unmounted volume"
end
