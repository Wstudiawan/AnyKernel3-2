# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=ExampleKernel by osm0sis @ xda-developers
do.devicecheck=1
do.modules=1
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=begonia
device.name2=begoniain
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/platform/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;


## AnyKernel install
dump_boot;

# begin ramdisk changes

X=10;
while [ $X != 0 ];
do
    patch_cmdline "zyc.gpu_clock" " ";
    X=$(($X-1));
done

# 0 900Mhz
# 1 897Mhz
# 2 892Mhz
# 3 888Mhz
# 4 884Mhz
# 5 880Mhz
# 6 875Mhz
# 7 871Mhz
# 8 867Mhz
# 9 862Mhz
# 10 858Mhz
# 11 854Mhz
# 12 850Mhz
# 13 835Mhz
# 14 821Mhz
# 15 806Mhz (default)
if [ -z "$(cat /tmp/zyc_kernelname | grep "Neutrino-Stock" )" ];then
    ui_print " ";
    GpuFreq="15";
    no=0;
    for ListFreq in 900 897 892 888 884 880 875 871 867 862 858 854 850 835 821 806; do
        if [ ! -z "$(cat /tmp/zyc_kernelname | grep "${ListFreq}Mhz" )" ];then
            GpuFreq="$no";
            [ "$no" != "15" ] && ui_print "GPU: set max clock to ${ListFreq}Mhz(oc)";
            [ "$no" == "15" ] && ui_print "use standard max clock 806Mhz(stock)";
            break;
        fi
        no=$(($no+1));
    done

    patch_cmdline "zyc.gpu_clock" "zyc.gpu_clock=$GpuFreq";
fi

ChangeSeLinux="-1";
if [ ! -z "$(cat /tmp/zyc_kernelname | grep "SetToEnforcing" )" ];then
    ChangeSeLinux="1";
    ui_print "SELinux will be forced to Enforcing by default";
elif [ ! -z "$(cat /tmp/zyc_kernelname | grep "SetToPermissive" )" ];then
    ChangeSeLinux="0";
    ui_print "SELinux will be forced to Permissive by default";
fi

if [ "$ChangeSeLinux" != "-1" ];then
    X=10;
    while [ $X != 0 ];
    do
        patch_cmdline "enforcing" " ";
        X=$(($X-1));
    done
    patch_cmdline "enforcing" "enforcing=$ChangeSeLinux";
fi

rm -rf /tmp/zyc_kernelname;

# end ramdisk changes

write_boot;
## end install