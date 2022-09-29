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

emmc_speed_test()
{
    # Args
    MB="$1"

    # Use DD to measure emmc speed
    TIME_STR=$(time dd if=/dev/zero of=/mnt/data/test bs=1M count=$MB 2>&1 | grep real)
    rm /mnt/data/test

    # Massage the output of dd into something we can do math with
    TIME_MINS=$(echo $TIME_STR | awk '{print substr($2, 1, length($2)-1)}')
    TIME_SECS=$(echo $TIME_STR | awk '{print substr($3, 1, length($3)-1)}')
    SECS=$(echo "($TIME_MINS * 60) + $TIME_SECS" | bc)

    # Echo back MB/s
    echo "$(echo "scale=2; $MB / $SECS" | bc)"
}

do_resize()
{
    # Ensure no data is waiting to be written
    sync

    # Resize data partition and remake filesystem with busybox defaults
    umount $EXPAND_PARTITION
    parted $EXPAND_DEVICE resizepart 4 100%
    yes | mkfs.ext4 $EXPAND_PARTITION
    e2label $EXPAND_PARTITION data
    mount $EXPAND_PARTITION
}

CHANGED_EMMC=0

# Check if the emmc is still 16MB
SIZE_VALUE=$(get_size_value $EXPAND_PARTITION)
echo "Initial emmc size: $SIZE_VALUE" | tee /root/emmc_results
if [ $SIZE_VALUE -eq 0 ]; then
    echo "Error while determining data size.  Unable to expand partition..." | tee -a /root/emmc_results
elif [ $SIZE_VALUE -le $FLASH_SECTORS ]; then
	CHANGED_EMMC=1

    echo "Resizing emmc" | tee -a /root/emmc_results
    do_resize
fi

#Check if the emmc is slow
PRE_SPEED_TEST=$(emmc_speed_test 100)
echo "Initial speed: $PRE_SPEED_TEST" | tee -a /root/emmc_results
if [ $(echo "$PRE_SPEED_TEST > 20" | bc) -eq 0 ]; then
	CHANGED_EMMC=1

    echo "Speed test too slow, reformatting /dev/mmcblk" | tee -a /root/emmc_results
    do_resize
    POST_SPEED_TEST=$(emmc_speed_test 100)
    echo "Post fix speed: $POST_SPEED_TEST" | tee -a /root/emmc_results
else
    echo "Emmc aleady fixed" | tee -a /root/emmc_results
fi

# Output partition size
SIZE_VALUE=$(get_size_value $EXPAND_PARTITION "-h")
echo "Data partition is $SIZE_VALUE" | tee -a /root/emmc_results

# If we changed anything about the emmc, copy that to the emmc
if [ $CHANGED_EMMC -eq 1 ]; then
	cat /root/emmc_results >> /mnt/data/emmc_results
fi

