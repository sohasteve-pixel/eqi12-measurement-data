# EQi12 Five Reboot Cycles — citable dataset

Row-per-cycle record of five consecutive scripted Windows reboots on the Beelink EQi12
on 2026-07-12. Every value is copied verbatim from the raw script log
`misc/EQi12_Reboot_5cycles.log`. No value is averaged, reconstructed or filled in.

- **File:** `dataset/EQi12_reboot_5cycles.csv` (UTF-8, comma-separated, all fields quoted)
- **Version:** 1.0 — 2026-11-22
- **Rows:** 5 cycles, 14 columns
- **License:** [CC BY 4.0](../LICENSE) — use, chart, reanalyse, with attribution
- **Canonical URL:** https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_reboot_5cycles.csv

## Why this file exists

This is the raw evidence behind the reboot-cycle layer of the site's stability-check
guide. It is published as a dataset so a third party can audit two claims a summary
would hide:

1. **The spread, not the fastest sample, is the finding.** Boot-to-network ranges
   43.07–106 s across five reboots of identical hardware — about 2.5x. Any single
   "my server boots in 40 seconds" claim is noise; recovery rate (5/5 unattended)
   and the observed range are the defensible statements.
2. **Network recovery and service recovery are different clocks.** Ethernet/gateway
   returns roughly two minutes before Jellyfin answers (boot-to-Jellyfin 162.66–226.94 s).
   The dataset keeps both columns separate so nobody conflates "ping works" with
   "the stack is actually serving."

This is a **warm reboot** dataset. It is distinct from the AC power-restore (G3,
cold power-cut) dataset `EQi12_ac_restore_g3_cycles.csv`; do not merge them.

## Field dictionary

| Column | Meaning |
|---|---|
| `cycle` | Reboot cycle number, 1–5. |
| `logon_check_local` | Timestamp of the `LOGON_CHECK` line, verbatim with `-07:00` offset. |
| `boot_time_local` | Boot timestamp on the same line (`Boot=`), verbatim. |
| `restart_scheduled_local` | Timestamp of the `RESTART_SCHEDULED` line, verbatim. |
| `boot_to_check_seconds` | Verbatim `BootToCheckSeconds`. |
| `ethernet` | Link state at recovery check (`Up` in all five). |
| `ipv4` | Address observed (`192.168.5.22` in all five). |
| `gateway` | Gateway reachability (`True` in all five). |
| `boot_to_network_seconds` | Verbatim `BootToNetworkSeconds` (Ethernet up + gateway reachable). |
| `jellyfin_http_answer` | Empty in every cycle: the raw `Jellyfin=` field carries no value. Left blank, not filled. |
| `boot_to_jellyfin_seconds` | Verbatim `BootToJellyfinSeconds` (media container answered). |
| `evidence` | `ScriptLog` — source is the script log; no phone video for this test. |
| `source_log` | Raw file relative to repository root. |
| `notes` | Per-row caveats. |

## A / B / C evidence boundary

- **A — directly measured on EQi12:** boot timestamps, boot-to-check, boot-to-network,
  boot-to-Jellyfin intervals, link/IPv4/gateway state, 5/5 unattended recovery.
- **B — component-level only:** Windows boot ordering and Docker Desktop/WSL2 auto-start
  behavior are platform characteristics; this file does not generalise to other hosts.
- **C — not measured:** application correctness after reboot, data integrity, cold-boot
  (G3) recovery, Proxmox-side reboot behavior. No number here speaks to those.

## Known traps

1. The raw `RECOVERY` line has **no timestamp** — only the `LOGON_CHECK` and
   `RESTART_SCHEDULED` lines do. Do not invent a recovery-line time.
2. `Jellyfin=` is empty in all five raw lines. The `jellyfin_http_answer` column is
   intentionally blank; the service-answer evidence is `boot_to_jellyfin_seconds`.
3. `boot_to_check`, `boot_to_network` and `boot_to_jellyfin` are three different
   intervals from boot. Do not average them together or swap one for another.
4. Five cycles is a small sample; the 43.07–106 s range is an observation, not a
   confidence interval. Judge regressions against your own baseline, not this range.
5. All cycles used the same wired Ethernet interface and address `192.168.5.22`.
   This dataset says nothing about Wi-Fi reconnect latency or DHCP re-acquisition.
6. Log timestamps carry a `-07:00` offset; the site article quotes them in local
   wall-clock time. Do not mix the two without stating the offset.
7. This is a Windows + Docker Desktop + WSL2 host. The Proxmox-side equivalent has
   not been run and is not in this dataset.

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 Five Reboot Cycles*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_reboot_5cycles.csv`.
