### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=MIUICX Kernel by TwinbornPlate75 @CoolAPK
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=raphael
device.name2=cepheus
device.name3=raphaelin
supported.versions=11-15
'; } # end properties

### AnyKernel install
# boot shell variables
block=auto;
is_slot_device=0;
ramdisk_compression=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
split_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

mv $home/rd-new.cpio $home/ramdisk-new.cpio

flash_dtbo;
flash_boot; # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
## end boot install
rm -rf /cache/*
rm -rf /data/dalvik-cache
rm -rf /data/resource-cache
rm -rf /data/system/package_cache
