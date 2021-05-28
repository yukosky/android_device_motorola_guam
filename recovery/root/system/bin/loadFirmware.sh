#!/system/bin/sh

# Pick from: https://raw.githubusercontent.com/TeamWin/android_device_motorola_cebu/android-10/recovery/root/system/bin/load_ts_firmware.sh
# Modified for guam by Velosh

touch_class_path=/sys/class/touchscreen
touch_path=
firmware_path=/vendor/firmware
firmware_file=

wait_for_poweron()
{
    local wait_nomore
    local readiness
    local count
    wait_nomore=60
    count=0
    while true; do
        readiness=$(cat $touch_path/poweron)
        if [ "$readiness" == "1" ]; then
            break;
        fi
        count=$((count+1))
        [ $count -eq $wait_nomore ] && break
        sleep 1
    done
    if [ $count -eq $wait_nomore ]; then
        return 1
    fi
    return 0
}

# Load all needed modules
insmod $module_path/chipone_tddi_mmi.ko
insmod $module_path/exfat.ko
insmod $module_path/fpc1020_mmi.ko
insmod $module_path/goodix_fod_mmi.ko
insmod $module_path/himax_v3_mmi_hx83102d.ko
insmod $module_path/himax_v3_mmi.ko
insmod $module_path/ili9882_mmi.ko
insmod $module_path/mmi_annotate.ko
insmod $module_path/mmi_info.ko
insmod $module_path/mmi_sys_temp.ko
insmod $module_path/moto_f_usbnet.ko
insmod $module_path/qpnp-power-on-mmi.ko
insmod $module_path/qpnp_adaptive_charge.ko
insmod $module_path/utags.ko

cd $firmware_path
touch_product_string=$(ls $touch_class_path)
firmware_file="ILITEK_FW_HLT.hex"

touch_path=/sys$(cat $touch_class_path/$touch_product_string/path | awk '{print $1}')
wait_for_poweron
echo $firmware_file > $touch_path/doreflash
echo 1 > $touch_path/forcereflash
sleep 5
echo 1 > $touch_path/reset

return 0
