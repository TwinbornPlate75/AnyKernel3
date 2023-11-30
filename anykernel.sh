### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=TPK by TwinbornPlate75
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=raphael
supported.versions=13-14
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

# boot shell variables
is_slot_device=auto;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# vendor_kernel_boot install
split_boot; # skip unpack/repack ramdisk, e.g. for dtb on devices with hdr v4 and vendor_kernel_boot

mv $home/rd-new.cpio $home/ramdisk-new.cpio

flash_boot;
## end install
