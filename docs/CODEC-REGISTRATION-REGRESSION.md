# Codec registration regression matrix

The historical dual-v2 source registered both AMR-WB codec implementations unconditionally. This allows the undesired packing format to appear in SDP even when `offer-both=0`.

The guarded registration in `source/mod_amrwb.dual-v2.c` is expected to behave as follows **for encoder/decoder builds**:

| offer-both | force-oa | Registered OA1 | Registered OA0/BE |
| --- | --- | --- | --- |
| 0 | 0 | No | Yes |
| 0 | 1 | Yes | No |
| 1 | 0 | Yes | Yes |
| 1 | 1 | Yes | Yes |

In `AMRWB_PASSTHROUGH` compilation, both variants remain registered to preserve historic behavior.

## Read-only verification on a matching build

1. Compile with matching FreeSWITCH headers and libraries; do not install an old binary on a newer FreeSWITCH version.
2. Run `fs_cli -x "show codecs"` after loading the correct freshly built module. Check OA1-only and OA0-only configurations independently.
3. Verify outbound INVITE SDP using `sngrep`: `a=rtpmap:<PT> AMR-WB/16000` followed by the correct `a=fmtp:<PT> octet-align=1` (or `0`).
4. Check response SDP, selected codec in `AMRWB INIT FINAL` logs and two-way audio. Preserve diagnostic SIP traces with secrets removed.
5. Repeat with OA0 inbound, OA1 inbound, PCMU fallback, and offer-less re-INVITE. Pay attention to dynamic payload mapping.
6. Restore module and XML backups if registration, negotiation or media fails.

**This is a targeted source-level correction, not proof of successful runtime media interoperability.** Confirm against the target FreeSWITCH version and real SIP/RTP captures before deploying.
