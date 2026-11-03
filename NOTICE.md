# Notices and provenance

This project archives independently supplied historical FreeSWITCH AMR-WB module modifications from September–October 2026.

- `source/mod_amrwb.dual-v2.c` is **derived from FreeSWITCH**; the original header credits Anthony Minessale II and other FreeSWITCH contributors, and states **Mozilla Public License 1.1**. Preserve the original notices and copyright.
- `source/mod_amrwb.dual-v2.patch` is a historical diff against an earlier local iteration. It is **not guaranteed to apply** to an upstream FreeSWITCH release.
- `experimental/` contains a separate older-base `no_modeset` attempt, not a successor to the dual-v2 implementation.
- The original author names in the upstream source have not been changed.
- Binaries, codec implementation libraries, customer call logs, proprietary configuration and internal host details are not distributed.
- Installing custom code in packaged deployments may affect package support and future upgrades; audit the changes and carry your own backups.
- AMR-WB codec licensing, patents and bundled third-party library obligations must be evaluated independently.
- Tested full SDP negotiation, two-way audio, mixed endpoints and modern FreeSWITCH compatibility are **not asserted** by this archive.
