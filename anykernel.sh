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
supported.versions=11-16
'; } # end properties

### AnyKernel install
# boot shell variables
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=1;
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

flash_boot;
flash_dtbo;
## end boot install

# cache clean
rm -rf /cache/*;
rm -rf /data/dalvik-cache;
rm -rf /data/resource-cache;
rm -rf /data/system/package_cache;
## end cache clean
