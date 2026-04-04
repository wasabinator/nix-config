# DSDT Patch: NVIDIA dGPU D3Cold Fix

## Problem

On hybrid AMD+NVIDIA laptops using the NVIDIA open kernel modules, the dGPU
refuses to stay in D3cold (powered off) at idle. It enters D3cold briefly then
immediately wakes back up in a ~12 second cycle, consuming ~12W even with no
processes using the GPU.

The root cause is a bug in the NVIDIA open kernel driver
([open-gpu-kernel-modules#905](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/905),
[#860](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/860)):
`rm_acpi_nvpcf_notify` calls `os_ref_dynamic_power` without checking whether
the dGPU is already in D3cold. Battery ACPI events from the Embedded Controller
(EC) trigger this handler, waking the GPU unnecessarily.

This is reported to affect the open kernel modules only, but I personally saw the same
behaviour with the proprietary driver.

## Confirming the Issue

Run these two commands simultaneously (requires `bpftrace`):

```bash
# Terminal 1 - watch GPU runtime status
sudo sh -c 'while true; do echo "$(date +%T) $(cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status)"; sleep 1; done'

# Terminal 2 - watch for nvidia resume calls
sudo bpftrace -e 'kretprobe:nv_pmops_runtime_resume { time("%H:%M:%S "); printf("nv_pmops_runtime_resume pid=%d\n", pid); }'
```

If the timestamps in both terminals correlate (GPU wakes up at the same moment
`nv_pmops_runtime_resume` fires), you have this bug.

## The Fix

The fix is to patch the DSDT (Differentiated System Description Table) to
remove the `Notify(NPCF, 0xC0)` calls in the EC Query methods that fire on
battery/power events. This prevents the ACPI event from ever reaching the
NVIDIA driver.

### Finding the Culprit Methods

Dump and decompile your DSDT:

```bash
nix-shell -p acpica-tools --run '
  sudo cat /sys/firmware/acpi/tables/DSDT > /tmp/dsdt.aml
  iasl -d /tmp/dsdt.aml
  grep -n "Notify.*NPCF.*0xC0\|Notify.*NPCF.*0xc0" /tmp/dsdt.dsl
'
```

Look for EC Query methods (`_Qxx`) containing `Notify(NPCF, 0xC0)`. On the
Razer Blade 14 2021 (5900HX + RTX 3070), the culprit methods were:

- `_Q30` - thermal/power mode change
- `_Q33` - AC/DC power state change  
- `_Q34` - power limit change

Your DSDT may differ. Check each method's context to identify which ones are
power/battery related.

### Patching

For each culprit method, remove the `Notify(NPCF, 0xC0)` and any associated
`Notify(PEGP, 0xC0)` lines, while leaving the rest of the method intact (e.g.
`CTGP` assignments which handle GPU power limits).

Also increment the `OemRevision` in the `DefinitionBlock` header - the kernel
will only use the override if its revision is higher than the firmware table:

```
DefinitionBlock ("", "DSDT", 2, "ALASKA", "A M I ", 0x01072009)
                                                      ^^^^^^^^^^
                                              increment this by 1
```

### NixOS Integration

The patched DSL is compiled and applied at boot via NixOS using a custom
derivation. See `custom-dsdt.nix` in this directory.

The derivation compiles `dsdt.dsl` with `iasl` and packages it into an
uncompressed cpio archive that the kernel loads before the main initrd.

**Important**: The cpio must be prepended before the AMD microcode update.
This is achieved using `lib.mkOrder 0` in `configuration.nix`:

```nix
boot.initrd.prepend = lib.mkOrder 0 [
  "${(pkgs.callPackage ./custom-dsdt.nix {})}/dsdt.cpio"
];
```

The kernel's ACPI table upgrade mechanism (`CONFIG_ACPI_TABLE_UPGRADE`) handles
the rest, replacing the firmware DSDT with the patched version at boot.

### Verifying the Fix

After rebooting, confirm the patched DSDT is being used:

```bash
sudo dmesg | grep -i "DSDT" | head -5
```

You should see:
```
ACPI: DSDT ACPI table found in initrd [kernel/firmware/acpi/dsdt.aml][...]
ACPI: Table Upgrade: override [DSDT-ALASKA-  A M I ]
ACPI: DSDT ... Physical table override, new table: ...
```

And confirm the GPU stays suspended:

```bash
watch -n1 'cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status'
```

---

## TGP Patch (Experimental — Parked on Branch)

> **Status**: Implemented and compiling, but currently inert. Parked on a
> separate branch pending NVPCF support in the open kernel driver. The D3cold
> patch above is unaffected and remains active on `main`.

### Background

The RTX 3070 Mobile in the Razer Blade 14 has a spec TGP of 100W, but under
Linux with the open kernel driver it is capped at ~34W on battery and ~40W on
AC. `nvidia-smi` reports the driver is aware of an 80W default limit and 100W
maximum, but the current power limit shows as `[N/A]`, meaning no TGP
negotiation is taking place.

### Investigation

The normal TGP negotiation path on Linux is via `nvidia-powerd`, which
communicates with the EC through the NVPCF ACPI interface. This requires the
`nvidia-cap` kernel module, which provides `/dev/nvidia-caps/`. This module is
**not present in the open kernel driver** — only in the proprietary driver.
Consequently `nvidia-powerd` exits immediately at startup and TGP negotiation
never occurs.

Confirmed by:

```bash
ls /dev/nvidia-caps/   # returns: no nvidia-caps
modinfo nvidia_cap     # returns: not found
```

And:

```bash
# nv_acpi_nvpcf_notify is not traceable in the open driver
nix-shell -p bpftrace --run "sudo bpftrace -e 'kretprobe:nv_acpi_nvpcf_notify { printf(\"fired\n\"); }'"
# WARNING: nv_acpi_nvpcf_notify is not traceable
```

### DSDT Analysis

Despite the open driver not listening for NVPCF notifications, the DSDT and
driver SSDT contain the full TGP negotiation structure. Key fields on the `NPCF`
device (defined in the nvidia-provided SSDT):

- `CTGP` — boolean flag; when `One`, enables boost TGP (`TGPA = ACBT`)
- `ACBT` — AC boost TGP value in watts (default `0x50` = 80W)
- `DCBT` — DC (battery) boost TGP
- `ATPP` — average TGP, set from EC register `RPL1 * 0x08`
- `DTPP` — DC average TGP
- `TGPA` / `TGPD` — final AC/DC TGP values communicated to the GPU

The EC actively gates TGP via three query methods:

- `_Q30` — sets `CTGP` based on thermal/performance mode (`TMMD`)
- `_Q33` — sets `CTGP` based on AC/DC state (`PSTA & 0x08`)
- `_Q34` — sets `ATPP` from `RPL1 * 0x08`, gated on AC power

### The Patch

The branch patches `dsdt.dsl` to:

1. Force `CTGP = One` unconditionally in `_Q30` and `_Q33`
2. Set `ACBT = 0x64` (100W) before enabling `CTGP`, overriding the SSDT
   default of 80W to match the hardware's rated maximum
3. Remove the AC-only gate in `_Q34` so `ATPP` is always set from `RPL1`

Additionally, `External (_SB_.NPCF.ACBT, UnknownObj)` is declared at the top
of the DSL since `ACBT` is an SSDT-owned field not previously referenced in the
DSDT.

### Why It Is Currently Inert

Even with `CTGP` and `ACBT` being set correctly by the DSDT, the open kernel
driver does not implement the NVPCF notification handler
(`nv_acpi_nvpcf_notify`) that would read these values and apply them as a power
budget to the GPU. The values are written to the NPCF device but never consumed.

### When This May Become Useful

If NVIDIA implements NVPCF support in the open kernel modules (analogous to the
`nvidia-cap` / `nvidia-powerd` path in the proprietary driver), the DSDT patch
should enable full 100W TGP negotiation without any further changes. The patch
is parked on the branch rather than deleted so it can be rebased and tested when
that support lands.

Watch: [open-gpu-kernel-modules](https://github.com/NVIDIA/open-gpu-kernel-modules/issues)
for NVPCF-related issues or PRs.

---

## References

- [NVIDIA open-gpu-kernel-modules #905](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/905)
- [NVIDIA open-gpu-kernel-modules #860](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/860)
- [Kernel ACPI initrd table override docs](https://docs.kernel.org/admin-guide/acpi/initrd_table_override.html)
- [NixOS Discourse: Overriding ACPI tables](https://discourse.nixos.org/t/overiding-acpi-tables-in-nixos/70944)
- [Arch Wiki: DSDT](https://wiki.archlinux.org/title/DSDT)
