#!/bin/sh

# Script variables
EXPAND_DEVICE=/dev/mmcblk0
EXPAND_PARTITION=${EXPAND_DEVICE}p4
FLASH_SECTORS=20000

get_line()
{
    # Prepare Arguments
    INPUT="$1"
    LINE_NUM=$2

    # Prepare string that will get us the line offset
    LINE_STR=$(printf "%dp" $LINE_NUM)

    # Get line and echo it to the caller
    echo "$(echo "$INPUT" | sed -n $LINE_STR)"
}

get_size_value()
{
    # Prepare arguments
    PARTITION=$1
    DF_ARGS="$2"

    # Get size information for partition
    SIZE_INFO=$(df $DF_ARGS $PARTITION | tr -s ' ' | cut -d' ' -f2)

    # Parse out information from info
    SIZE_LABEL=$(get_line "$SIZE_INFO" 1)
    SIZE_VALUE=$(get_line "$SIZE_INFO" 2)

    # Set default value and determine if the info we have is valid
    SIZE=0
    if [ $SIZE_LABEL == "1K-blocks" ] || [ $SIZE_LABEL == "Size" ]; then
        SIZE=$SIZE_VALUE
    fi

    # Echo the size to the caller
    echo $SIZE
}

SIZE_VALUE=$(get_size_value $EXPAND_PARTITION)

if [ $SIZE_VALUE -eq 0 ]; then
    echo "Error while determining data size.  Unable to expand partition..."
elif [ $SIZE_VALUE -le $FLASH_SECTORS ]; then
    echo "Expanding data partition size"
    # Ensure no data is waiting to be written
    sync

    # Resize data partition and remake filesystem with busybox defaults
    umount $EXPAND_PARTITION
    parted $EXPAND_DEVICE resizepart 4 100%
    mkfs.ext4 $EXPAND_PARTITION
    e2label $EXPAND_PARTITION data
    mount $EXPAND_PARTITION
fi

# Output partition size
SIZE_VALUE=$(get_size_value $EXPAND_PARTITION "-h")
echo "Data partition is $SIZE_VALUE"
