# FreeSWITCH / FusionPBX AMR-WB recovery & octet-align experiments

**Community recovery notes and historical source for `mod_amrwb`.** Helps diagnose a missing `mod_amrwb.so` after a FreeSWITCH/FusionPBX upgrade, rebuild the module against a matching FreeSWITCH source tree, and verify AMR-WB octet-aligned (`octet-align=1`) SDP/RTP behavior.

> **Status:** Historical, experimental source collected in September–October 2026, originally worked on against **FreeSWITCH 1.10.9**. **Not a tested drop-in fix for every FreeSWITCH version.** No precompiled binaries. Verify source/ABI compatibility and licensing before installing. Do not deploy directly to production.

## Start here

1. [Original custom AMR-WB source](source/mod_amrwb.dual-v2.c) — OA0/OA1 implementation and codec negotiation changes.
2. [Historical patch](source/mod_amrwb.dual-v2.patch) — relative to an earlier local build, not a clean upstream patch.
3. [Example configurations](examples/) — OA1 and dual-offer experimental settings.
4. [Build and rollback notes](docs/BUILD-AND-ROLLBACK.md) and [SDP checks](docs/SDP-VALIDATION.md) — optional reference for anyone restoring the module after an upgrade.

## Repository layout

| Path | Content |
| --- | --- |
| `source/mod_amrwb.dual-v2.c` | Historical customized FreeSWITCH C module, OA0/OA1 registration, `offer-both` and `force-oa` logic and log diagnostics |
| `source/mod_amrwb.dual-v2.patch` | Historical diff **against an earlier local version**, not a guaranteed patch for pristine upstream |
| `examples/amrwb-oa1.conf.xml` | OA1-oriented lab configuration |
| `examples/amrwb-dual-experimental.conf.xml` | Dual-offer lab configuration (requires independent validation) |
| `experimental/patch_amrwb_1_10_9.py` | Separate, **experimental** no-`mode-set` source generator for exact 1.10.9 input |
| `experimental/mod_amrwb_no_modeset_xrmx.c` | Separate historical no-`mode-set` experiment, **not** the OA dual-v2 source |

**Important:** A source-level fix now registers OA1 only when `offer-both=0; force-oa=1`, OA0 only when both are `0`, and both formats when `offer-both=1` (for encoder/decoder builds). This is **not yet validated against a running FreeSWITCH build**; confirm actual offer and answer in a SIP trace. See [codec registration regression matrix](docs/CODEC-REGISTRATION-REGRESSION.md). The experimental no-`mode-set` script and C file are **different approaches** and must not be mixed into the dual-v2 build without review.

## Typical symptom

```text
Error Loading module /usr/lib/freeswitch/mod/mod_amrwb.so:
cannot open shared object file: No such file or directory
```

This first means the module is missing from the directory the runtime expects. It does **not** establish the source code is broken. Check runtime paths, installed files, package inventory and shared-library dependencies **before** changing codec configuration. A source-matched build may be needed after an upgrade.

## Requirements and caveats

- Use the source tree, headers, toolchain, architecture and build flags matching the running FreeSWITCH package. **Never copy an old `.so` blindly after an upgrade.**
- For decode/encode support (rather than pass-through), appropriate `opencore-amrwb` and `vo-amrwbenc` development libraries are needed. Verify build flags and loaded dependencies.
- The C source retains original FreeSWITCH authorship and **MPL 1.1** notices. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md). AMR-WB codec patents/third-party component licenses may apply separately.
- No dialplan, SIP credentials, internal server logs, recordings or customer configuration are included.
- This is a research/recovery archive, not a formally certified interoperable codec patch. Please contribute reproducible SIP traces with private data removed, version numbers and verified fixes.

## References

- [FreeSWITCH codecs and AMR-WB settings](https://developer.signalwire.com/freeswitch/media-and-codecs/codecs/)
- [FreeSWITCH module loading](https://developer.signalwire.com/freeswitch/configuration/module-loading/)
- [FreeSWITCH source build](https://developer.signalwire.com/freeswitch/foundations/getting-started/)
- [AMR payload format — RFC 4867](https://www.rfc-editor.org/rfc/rfc4867)
- [FreeSWITCH upstream](https://github.com/signalwire/freeswitch)

## License

Historical FreeSWITCH-derived source: **MPL-1.1** with original notices preserved. Other repository documentation and helper scripts are also offered under MPL-1.1. Third-party decoder/encoder libraries are not bundled; check their own licenses and applicable patents.
