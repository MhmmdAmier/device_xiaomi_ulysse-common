#!/vendor/bin/sh

case "$(cat /sys/firmware/devicetree/base/model)" in
	"Qualcomm Technologies, Inc. MSM8917-PMI8937 MTP")
		setprop ro.vendor.xiaomi.device ugglite
                setprop ro.vendor.fingerprint.supported 0
		;;
	"Qualcomm Technologies, Inc. MSM8940-PMI8937 MTP")
		setprop ro.vendor.xiaomi.device ugg
		# Camera
		setprop persist.s5k3p8sp.flash.low 320
		setprop persist.s5k3p8sp.flash.light 300
		setprop persist.ov16885.flash.low 290
		setprop persist.ov16885.flash.light 275
		# Fingerprint
		setprop ro.vendor.fingerprint.supported 1
		;;
esac

exit 0
