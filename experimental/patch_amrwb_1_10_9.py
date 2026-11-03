#!/usr/bin/env python3
"""Generate a FreeSWITCH v1.10.9 mod_amrwb.c without generated mode-set.
Run from a matching source tree or pass the existing mod_amrwb.c path.
No install/restart or overwrite is performed.
"""
from pathlib import Path
import sys

source = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('src/mod/codecs/mod_amrwb/mod_amrwb.c')
if not source.is_file():
    raise SystemExit(f'Source not found: {source}')
s = source.read_text()
line = 'snprintf(buf + strlen(buf), sizeof(buf) - strlen(buf), "mode-set=%d; ", globals.default_bitrate);'
if s.count(line) != 1:
    raise SystemExit('Expected FreeSWITCH 1.10.9 default FMTP line not found exactly once.')
s = s.replace(line, '/* No mode-set in initial AMR-WB offer (test build). */')

begin = '\t\tif (context->enc_modes && !globals.mode_set_overwrite) {'
end = '\t\tcodec->fmtp_out = switch_core_strdup(codec->memory_pool, fmtptmp);'
if s.count(begin) != 1 or s.count(end) != 1:
    raise SystemExit('Expected FreeSWITCH 1.10.9 codec fmtp_out section not found exactly once.')
start = s.index(begin)
stop = s.index(end, start)
replacement = '''\
        /* Test build: preserve chosen encoding mode but omit mode-set from SDP. */
        if (context->enc_modes && !globals.mode_set_overwrite) {
            for (i = SWITCH_AMRWB_MODES-2; i > -1; i--) {
                if (context->enc_modes & (1 << i)) {
                    context->enc_mode = (switch_byte_t) i;
                    break;
                }
            }
        }

        if (globals.adjust_bitrate) {
            switch_set_flag(codec, SWITCH_CODEC_FLAG_HAS_ADJ_BITRATE);
        }

        fmtptmp_pos = switch_snprintf(fmtptmp, sizeof(fmtptmp), "octet-align=%d",
                            switch_test_flag(context, AMRWB_OPT_OCTET_ALIGN) ? 1 : 0);
        if (globals.volte) {
            switch_snprintf(fmtptmp + fmtptmp_pos, sizeof(fmtptmp) - fmtptmp_pos,
                            ";max-red=0;mode-change-capability=2");
        }

'''
s = s[:start] + replacement + s[stop:]
if s.count('"mode-set='):
    raise SystemExit('A generated mode-set value remains: not writing patch.')
target = source.with_name('mod_amrwb_no_modeset.c')
if target.exists():
    raise SystemExit(f'Target already exists; refusing to overwrite {target}')
target.write_text(s)
print(f'Created {target}')
print(f'Review: diff -u {source} {target}')