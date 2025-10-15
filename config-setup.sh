#!/usr/bin/env bash
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s nongki

scripts/config --file out/.config --enable CONFIG_KPM
scripts/config --file out/.config --enable CONFIG_KALLSYMS
scripts/config --file out/.config --enable CONFIG_KALLSYMS_ALL
scripts/config --file out/.config --enable MODULES
scripts/config --file out/.config --enable MODULE_UNLOAD
scripts/config --file out/.config --enable OVERLAY_FS
scripts/config --file out/.config --enable CONFIG_KSU_MANUAL_HOOK

#cripts/config --file out/.config --enable CONFIG_SUSFS || true
#cripts/config --file out/.config --enable KSU_SUSFS_HAS_MAGIC_MOUNT || true

# Disable problematic options
scripts/config --file out/.config --disable EFI
scripts/config --file out/.config --disable EFI_STUB
scripts/config --file out/.config --disable RANDOMIZE_BASE
