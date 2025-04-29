### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Starfish Kernel by TwinbornPlate75 @ CoolAPK
do.devicecheck=1
do.cleanup=1
device.name1=OnePlus7
device.name2=guacamoleb
device.name3=OnePlus7Pro
device.name4=guacamole
device.name5=OnePlus7ProTMO
device.name6=guacamolet
device.name7=OnePlus7T
device.name8=hotdogb
device.name9=OnePlus7TPro
device.name10=hotdog
device.name11=OnePlus7TProNR
device.name12=hotdogg
supported.versions=11-15
'; } # end properties

### AnyKernel install
# boot shell variables
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=1;
NO_BLOCK_DISPLAY=1;
RAMDISK_COMPRESSION=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# patch dtb if using retrofit dynamic partitions
grep -q "logical" /vendor/etc/fstab.qcom
if [ $? -eq 0 ]; then
    ui_print " " "Retrofit dynamic partitions detected. Patching dtb...";
    fdtput -t s $AKHOME/dtb /firmware/android/boot_devices "soc/1d84000.ufshc";
    fdtput -d $AKHOME/dtb /firmware/android/shared_meta;
    fdtput -d $AKHOME/dtb /firmware/android/android_q_fstab;

    DSP=true;
else
    # patch dtb if using erofs on /vendor
    fs_type=$($AKHOME/tools/busybox mount | grep ' /vendor ' | awk '{print $5}');
    if [ "$fs_type" = "erofs" ]; then
        ui_print " " "EROFS filesystem type on /vendor detected. Patching dtb...";
        fdtput $AKHOME/dtb /firmware/android/android_q_fstab/vendor type "erofs";
        fdtput $AKHOME/dtb /firmware/android/android_q_fstab/vendor mnt_flags "ro";
    fi;
fi;

# boot install
split_boot;
if [ "$DSP" = "true" ]; then
    patch_cmdline "using_dynamic_partitions" "using_dynamic_partitions";
fi;
flash_boot;
flash_dtbo;
## end boot install

# cache clean
rm -rf /cache/*;
rm -rf /data/dalvik-cache;
rm -rf /data/resource-cache;
rm -rf /data/system/package_cache;
## end cache clean
