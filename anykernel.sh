# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=TPKernel by TwinbornPlate75
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=raphael
supported.patchlevels=
'; } # end properties

# shell variables
block=auto;
is_slot_device=auto;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel install
split_boot;

mv $home/rd-new.cpio $home/ramdisk-new.cpio

flash_boot;
## end install
