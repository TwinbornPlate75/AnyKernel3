### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=MIUICX Kernel by TwinbornPlate75 @ CoolAPK
do.devicecheck=1
do.cleanup=1
device.name1=raphael
device.name2=raphaelin
device.name3=cepheus
supported.versions=11-16
'; } # end properties

### AnyKernel install
# boot shell variables
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=0;
NO_BLOCK_DISPLAY=1;
RAMDISK_COMPRESSION=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# import inject functions
. tools/inject.sh;

# boot install
split_boot;

ui_print " " "Analyzing libhwui.so for injection points...";
INJECTION_OFFSETS=""
if [ -f "/system/lib64/libhwui.so" ]; then
    INJECTION_OFFSETS=$(analyze_libhwui "/system/lib64/libhwui.so" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$INJECTION_OFFSETS" ]; then
        ui_print " " "Injection points found: $INJECTION_OFFSETS";
        INJECT1=$(echo "$INJECTION_OFFSETS" | cut -d' ' -f1)
        INJECT2=$(echo "$INJECTION_OFFSETS" | cut -d' ' -f2)
        patch_cmdline "hwui_inject1" "hwui_inject1=$INJECT1";
        patch_cmdline "hwui_inject2" "hwui_inject2=$INJECT2";
    else
       ui_print " " "Failed to analyze libhwui.so";
    fi
fi

# patch dtb if using retrofit dynamic partitions
grep -q "logical" /vendor/etc/fstab.qcom
if [ $? -eq 0 ]; then
    ui_print " " "Retrofit dynamic partitions detected. Patching dtb...";
    fdtput -t s $AKHOME/dtb /firmware/android/boot_devices "soc/1d84000.ufshc";
    fdtput -d $AKHOME/dtb /firmware/android/shared_meta;
    fdtput -d $AKHOME/dtb /firmware/android/android_q_fstab;

    patch_cmdline "using_dynamic_partitions" "using_dynamic_partitions";
else
    # patch dtb if using erofs on /vendor
    fs_type=$($AKHOME/tools/busybox mount | grep ' /vendor ' | awk '{print $5}');
    if [ "$fs_type" = "erofs" ]; then
        ui_print " " "EROFS filesystem type on /vendor detected. Patching dtb...";
        fdtput $AKHOME/dtb /firmware/android/android_q_fstab/vendor type "erofs";
        fdtput $AKHOME/dtb /firmware/android/android_q_fstab/vendor mnt_flags "ro";
    fi
fi

flash_boot;
flash_dtbo;
## end boot install

# cache clean
rm -rf /cache/*;
rm -rf /data/dalvik-cache;
rm -rf /data/resource-cache;
rm -rf /data/system/package_cache;
## end cache clean
