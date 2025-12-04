### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Starfish Kernel by TwinbornPlate75 @ CoolAPK
do.devicecheck=0
do.cleanup=1
device.name1=
device.name2=
supported.versions=11-16
'; } # end properties

### AnyKernel install
# boot shell variables
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=1;
NO_BLOCK_DISPLAY=1;

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
## end boot install

# cache clean
rm -rf /cache/*;
rm -rf /data/dalvik-cache;
rm -rf /data/resource-cache;
rm -rf /data/system/package_cache;
## end cache clean
