# AMR-WB SDP/RTP validation checklist

A codec appearing in FusionPBX or `fs_cli -x "show codecs"` is not sufficient. Verify **actual SIP SDP offers/answers** and **two-way RTP audio**.

## Check the offer

An OA1 example (dynamic payload type is only illustrative):

```sdp
m=audio 30000 RTP/AVP 112 0 8
a=rtpmap:112 AMR-WB/16000
a=fmtp:112 octet-align=1;mode-set=0,1,2
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
```

The `fmtp` may include more fields. `mode-set` is codec bitrate-mode signaling, **not** an alternative to `octet-align`. You may see different PT values than 112. For OA0 the corresponding `octet-align` is 0 (or absent if the peer follows default bandwidth-efficient behavior).

## Check the answer

- AMR-WB/16000 negotiated at the correct dynamic PT, with a compatible `octet-align`.
- If the peer does not support it, verify intentional fallback to PCMU/PCMA rather than an audio blackhole.
- Confirm `mode-set` handling is accepted by the remote gateway; use the separate experimental no-`mode-set` source **only in a controlled lab**.
- Test inbound and outbound legs independently, especially if an SBC/B2BUA changes SDP or handles media.

## Check media

- Establish and play a test call with speech **in both directions**.
- Check that actual RTP packetization matches negotiated OA0/ OA1, not merely the SDP text.
- Test codec transcoding/bridging where required, and verify that the module loaded the decoder and encoder libraries.
- Verify offer-less re-INVITE, standard re-INVITE and ACK handling if these are part of the environment.
- Collect sanitized SIP ladders + RTP summary and compare against an earlier known-good baseline.

## Diagnostics

```bash
fs_cli -x 'version'
fs_cli -x 'module_exists mod_amrwb'
fs_cli -x 'show codecs' | grep -i 'AMR'
# Example: site-specific FreeSWITCH log
grep -i 'AMRWB INIT FINAL' /var/log/freeswitch/freeswitch.log | tail -n 20
```

The custom September `dual-v2` code emits `AMRWB INIT FINAL` on codec initialization; log volume should be considered. Do not publish unredacted SIP traces or credentials.

## Standards / upstream

- RFC 4867: https://www.rfc-editor.org/rfc/rfc4867
- Upstream FreeSWITCH codecs guide: https://developer.signalwire.com/freeswitch/media-and-codecs/codecs/
