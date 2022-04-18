#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE_COMMON=ulysse-common
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="../../../extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=false

ONLY_COMMON=
ONLY_TARGET=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                ;;
        --only-target )
                ONLY_TARGET=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

if [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

    extract "${MY_DIR}/proprietary-files-qc.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    extract "${MY_DIR}/../${DEVICE}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

# Hax for cam configs
sed -i "s|/system/etc/camera/|/vendor/etc/camera/|g" "$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib/libmmcamera2_sensor_modules.so

# Wrap libgui_vendor into libwui
sed -i "s/libgui/libwui/g" "$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib/libmmsw_platform.so
sed -i "s/libgui/libwui/g" "$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib/libmmcamera_ppeiscore.so
sed -i "s/libgui/libwui/g" "$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib/libmmcamera2_stats_modules.so
sed -i "s/libgui/libwui/g" "$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib/libmmsw_detail_enhancement.so
sed -i "s/libgui/libwui/g" "$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib64/libmmsw_platform.so
sed -i "s/libgui/libwui/g" "$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib64/libmmsw_detail_enhancement.so

# Shim libandroid for camera blobs
patchelf --replace-needed libandroid.so libandroid_shim.so "$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib/libmmcamera2_stats_modules.so
patchelf --replace-needed libandroid.so libandroid_shim.so "$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib/libmpbase.so

# Hex edit libwfdnative.so to link missing symbols
"$ANDROID_ROOT"/vendor/"$VENDOR"/"$DEVICE_COMMON"/proprietary/vendor/lib64/libwfdnative.so)
    patchelf --add-needed "libshim_wfd.so" "${2}"
    ;;

# IMS
"${PATCHELF}" --add-needed "libims-shim.so" "${DEVICE_BLOB_ROOT}"/system_ext/lib64/lib-imsvideocodec.so

"$MY_DIR/setup-makefiles.sh"