# Contributing

Thank you for helping FreeSWITCH/FusionPBX users recover and test AMR-WB.

## What helps most

- Reproducible problems with the exact FreeSWITCH version/commit, Linux distribution, CPU architecture, and module build strategy.
- A sanitized SIP offer/answer showing AMR-WB dynamic PT, `octet-align`, and `mode-set`.
- Whether encoder/decoder libraries are linked or the module is pass-through only.
- Two-way audio results, PCMU/PCMA fallback result, and whether a re-INVITE was involved.
- Patches rebased onto a **named upstream FreeSWITCH tag or commit**, with an explanation of ABI changes.
- Any test or validation that demonstrates OA0 and OA1 behavior independently.

## Do not publish

Credentials, authentic SIP auth headers, production IP addresses, customer DID lists, call recordings, private keys, internal cloud identifiers, or unsanitized logs.

## Pull request guidelines

1. Describe the exact failure and expected SDP/media result.
2. Include before/after sanitized traces or a minimal test.
3. Document your compiler, FreeSWITCH version, OS and codec library versions.
4. Preserve existing upstream license headers and attribute original contributors.
5. Do not claim verified support for newer FreeSWITCH versions without a reproducible test.

## Scope

This is a community archive of experimental recovery work, not an upstream FreeSWITCH release. Prefer configuration/package-based repairs when possible, and carefully review all codec source changes.
