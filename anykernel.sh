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
supported.versions=11-15
'; } # end properties

### AnyKernel install
# boot shell variables
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=1;
NO_BLOCK_DISPLAY=1;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
split_boot;
flash_boot;
## end boot install

# cache clean
rm -rf /cache/*;
rm -rf /data/dalvik-cache;
rm -rf /data/resource-cache;
rm -rf /data/system/package_cache;
## end cache clean
