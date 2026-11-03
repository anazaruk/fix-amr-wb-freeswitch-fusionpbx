#!/usr/bin/env bash
# Read-only FreeSWITCH / FusionPBX AMR-WB inventory.
# Does not install packages, edit files, load modules, or restart services.
set -u

section() { printf '\n== %s ==\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

section "Platform"
if have uname; then uname -srm; fi
if test -r /etc/os-release; then sed -n '1,8p' /etc/os-release; fi

section "FreeSWITCH version and runtime module directory"
if have fs_cli; then
  fs_cli -x 'version' || true
  fs_cli -x 'global_getvar mod_dir' || true
  fs_cli -x 'module_exists mod_amrwb' || true
  fs_cli -x 'show codecs' 2>/dev/null | grep -i 'AMR' || true
else
  echo 'fs_cli not found'
fi

section "Relevant installed packages (Debian/Ubuntu)"
if have dpkg-query; then
  dpkg-query -W 'freeswitch*' 'libopencore-amrwb*' 'libvo-amrwbenc*' 2>/dev/null || true
fi

section "AMR-WB files and preserved builds"
for root in /usr/lib/freeswitch /usr/local/freeswitch /usr/src/freeswitch /root/amrwb_versions; do
  if test -d "$root"; then
    find "$root" -name '*amrwb*' -print 2>/dev/null || true
  fi
done

section "Available encoder and decoder runtime libraries"
if have ldconfig; then
  ldconfig -p 2>/dev/null | grep -E 'libopencore-amrwb|libvo-amrwbenc' || true
fi

section "Configured module autoload"
if test -r /etc/freeswitch/autoload_configs/modules.conf.xml; then
  grep -n 'mod_amrwb' /etc/freeswitch/autoload_configs/modules.conf.xml || true
fi

section "Configured AMR-WB parameters"
if test -r /etc/freeswitch/autoload_configs/amrwb.conf.xml; then
  grep -n -E 'default-bitrate|volte|adjust-bitrate|offer-both|force-oa|mode-set-overwrite' /etc/freeswitch/autoload_configs/amrwb.conf.xml || true
fi

printf '\nThis was a read-only inventory. Redact environment-specific details before sharing publicly.\n'
