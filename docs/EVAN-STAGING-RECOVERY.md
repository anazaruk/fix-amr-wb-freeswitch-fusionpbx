# Evan: restore AMR-WB on FusionPBX staging

## What happened

FusionPBX was upgraded and FreeSWITCH cannot open `mod_amrwb.so` at its expected module path. The historical implementation was custom-built, not supplied by the ordinary package. See `source/mod_amrwb.dual-v2.c` for the original source and `source/mod_amrwb.dual-v2.patch` for its local development patch.

## Please collect these facts first

1. Installed FreeSWITCH version, OS/architecture and package build information.
2. Actual runtime module directory and whether `mod_amrwb.so` exists there.
3. Whether any earlier compiled module or build tree survives in `/root/amrwb_versions` or `/usr/src/freeswitch`.
4. Encoder and decoder libraries and their development packages, if transcoding is needed.
5. The current AMR-WB and module autoload XML configuration.

Use the separate [read-only commands in BUILD-AND-ROLLBACK.md](BUILD-AND-ROLLBACK.md) as a starting point.

## Recommended process

1. Preserve snapshots and backup all relevant module/config files.
2. Determine whether a package for the installed FreeSWITCH version is available.
3. If custom OA behavior is required, review the archived source and **rebase** the changes onto the exact FreeSWITCH source version matching the installed runtime.
4. Build in staging, inspect shared library dependencies and confirm it loads successfully.
5. Review [the OA1 lab XML](../examples/amrwb-oa1.conf.xml); `force-oa=1` does **not** guarantee OA1-only advertising with this historical source.
6. Validate a SIP to PSTN test call and reverse-direction call by examining SDP and hearing speech in both directions.
7. If negotiation or audio fails, restore the pre-change FreeSWITCH module/configuration and test PCMU/PCMA fallback.

**Do not copy a historical binary compiled for 1.10.9 into a newer FreeSWITCH deployment.** Details: [build instructions](BUILD-AND-ROLLBACK.md) and [SDP validation](SDP-VALIDATION.md).

## Send back

Please share the version, module location, backup inventory, build result, sanitized SDP of the offered and accepted codec, and whether two-way audio worked. Do not share SIP authentication secrets, private IP addresses, customer call recordings, or raw customer call logs in this public repository.
