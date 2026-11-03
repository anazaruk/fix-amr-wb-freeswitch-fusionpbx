# Build, installation and rollback (administrator guide)

**No universal one-command installer is provided.** FreeSWITCH ABI, header declarations, package layout and module directory vary. This archive contains source from an earlier 1.10.9-era build and is not guaranteed compatible with 1.10.12 or 1.11.x.

## 1. Snapshot / preserve

- Take a VM or filesystem snapshot.
- Record FreeSWITCH version and installed packages.
- Back up the **actual** module path and `amrwb.conf.xml`, `modules.conf.xml`, and any relevant Sofia profile changes, preserving ownership and timestamps.
- If possible, create rollback tarball somewhere outside this public repository. Never commit private configuration, logs, call metadata or credentials.

## 2. Match your source tree and toolchain

Use the source tag/commit and configure options corresponding to the installed binary. A stock source checkout with different build flags can produce an incompatible module. Check your package build metadata, running version, `pkg-config`, and library layout.

For Debian-based hosts, these may provide encoder/decoder **headers** if available in your configured package repositories:

```bash
apt-cache policy libopencore-amrwb-dev libvo-amrwbenc-dev
apt-cache policy libopencore-amrwb0 libvo-amrwbenc0
```

The exact package names vary by OS/release. Install only as part of an approved staging maintenance procedure.

## 3. Rebase custom source instead of blind replacement

Compare `source/mod_amrwb.dual-v2.c` against the matching upstream FreeSWITCH `src/mod/codecs/mod_amrwb/mod_amrwb.c` using `diff -u`. It uses source-tree-local `bitshift.h` and `amrwb_be.h` and must be built inside a compatible source tree.

- The archived `.patch` is only a **historical local delta**.
- The separate no-mode-set version has different base source and scope; it is **not** an interchangeable replacement.
- Confirm that codec implementations have the correct default `fmtp` values and that calls negotiate the expected implementation rather than merely advertise two entries.
- Do not overwrite the distro's source tree without a clean copy.

In a configured, matching FreeSWITCH source tree, inspect available build targets before doing anything:

```bash
grep -n 'codecs/mod_amrwb' modules.conf || true
make -n mod_amrwb 2>&1 | head -n 40
make -n mod_amrwb-install 2>&1 | head -n 40
```

Only if those targets are supported and the build is correctly configured, invoke the matching build target (`make mod_amrwb` or the target appropriate to your FreeSWITCH checkout). **Do not run a global `make install` for an existing packaged server without a carefully reviewed deployment plan.**

## 4. Inspect output before deploying

```bash
file /path/to/build/mod_amrwb.so
readelf -d /path/to/build/mod_amrwb.so | grep -E 'NEEDED|RPATH|RUNPATH'
ldd -r /path/to/build/mod_amrwb.so
```

`ldd -r` should not report unexpected missing shared libraries or unresolved symbols. Check if the encoder and decoder dependencies are linked when full media processing is required. FreeSWITCH's documentation states that AMR-WB without `opencore-amrwb` and `vo-amrwbenc` builds in pass-through mode only.

## 5. Deploy under change control

- Copy the inspected artifact into the runtime's **actual** module directory, not a guessed path.
- Restore module ownership/mode consistent with other installed modules.
- Configure `autoload_configs/modules.conf.xml` if the module should load after a restart.
- Configure `autoload_configs/amrwb.conf.xml` for the intended experiment.
- Attempt a controlled dynamic load or restart, according to the local operational procedures, **only after existing calls are drained or impact accepted**.
- Prove two-way media and rollback with a staging test.

## 6. Rollback

Keep a timestamped backup of old module and relevant configs; restore all of them together if the new module fails, then validate baseline PCMU/PCMA calls. If the module was absent before the change, remove the newly added file/loader entry on rollback.

## Dependency and license notes

No pre-built AMR-WB binary or third-party codec library is redistributed. Review MPL-1.1 notices and applicable AMR-WB codec licensing/patents for deployment in your jurisdiction.

References: https://developer.signalwire.com/freeswitch/media-and-codecs/codecs/ and https://www.rfc-editor.org/rfc/rfc4867.
