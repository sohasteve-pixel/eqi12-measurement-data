# EQi12 AC Power-Restore (State After G3) Cycles — citable dataset

Row-per-record record of the three power-cut / AC-restore cycles run on the Beelink EQi12
on 2026-07-12, with BIOS `State After G3 = S0` (restore power after loss). Every value is
copied verbatim from the raw script log `docker/EQi12_G3_ACRestore_3cycles.log` and the
written conclusion `docker/EQi12_StateAfterG3_3轮结论.txt`. No value is averaged or
reconstructed.

- **File:** `dataset/EQi12_ac_restore_g3_cycles.csv` (UTF-8, comma-separated, all fields quoted)
- **Version:** 1.0 — 2026-11-21
- **Rows:** 4 records, 17 columns (1 invalid + 1 corrected + 2 valid cycles)
- **License:** [CC BY 4.0](../LICENSE) — use, chart, reanalyse, with attribution
- **Canonical URL:** https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_ac_restore_g3_cycles.csv

## Why this file exists

This is the raw evidence behind the site's AC-power-recovery guide. It is published as a
dataset so a third party can audit two claims that a summary would otherwise hide:

1. **Cycle 1 appears twice, on purpose.** The first `Cycle 1 COMPLETE` line is an
   incomplete read from a restricted shell — boot time equals check time (`BootToCheckSeconds=0`),
   no IPv4, no interface, no container start. The following `Cycle 1 CORRECTED` line is the
   authoritative value (241.05 s boot-to-check). The invalid row is retained, not deleted,
   so nobody can mistake a `0 s` reading for a real recovery time.
2. **"3/3 PASS" is a boot/network/Jellyfin check, not an application benchmark.** The
   script verified automatic power-on, Ethernet link, a DHCP address, an HTTP 200 from
   Jellyfin and a running container. It did not measure transcode performance, storage
   integrity under sudden power loss, or filesystem journaling. Do not cite this as
   "the EQi12 survives power cuts without data loss."

## Field dictionary

| Column | Meaning |
|---|---|
| `test_group` | Always `G3_AC_RESTORE`. Partition key if more groups are appended. |
| `cycle` | Test cycle number (1–3). Cycle 1 has two records; see `record_status`. |
| `record_status` | `COMPLETE_INVALID` (restricted-read artifact) / `CORRECTED_VALID` (authoritative replacement for cycle 1) / `COMPLETE_VALID`. |
| `auto_power_on` | `PASS` = machine booted with no power-button press after AC was restored. |
| `boot_time_local` | Boot timestamp from the log, local time with `-07:00` offset, verbatim. |
| `check_time_local` | Timestamp of the health check, same local offset. |
| `boot_to_check_seconds` | Elapsed seconds boot → check, verbatim from `BootToCheckSeconds`. |
| `network_check` | `PASS` = link up and reachable. |
| `interface` | `Ethernet` where the line recorded it; blank on the invalid cycle-1 read. |
| `mac` | Interface MAC where recorded. Only cycle 3 logged `78-55-36-08-FF-8E`. |
| `ipv4` | Address observed at check time; blank on the invalid line. |
| `jellyfin_http` | HTTP status returned by Jellyfin; `200` in all valid cycles. |
| `jellyfin_container_started_local` | Container start time, verbatim log format (`M/D/YYYY h:mm:ss AM/PM`), local time. |
| `boot_to_container_start_seconds` | Boot → Jellyfin container start, verbatim from `BootToContainerStartSeconds`. `NA` on the invalid line. |
| `evidence` | `PhoneVideo` = phone video of the physical power cut, restore and automatic boot. |
| `source_logs` | Raw files the row was copied from, relative to the repository root. |
| `notes` | Per-row caveats and what the record does / does not prove. |

## A / B / C evidence boundary

- **A — directly measured on EQi12:** power-on success, Ethernet/IPv4 recovery, Jellyfin
  HTTP 200, container start times, and the three boot-to-check intervals.
- **B — component-level only:** the BIOS `State After G3 = S0` behavior is a firmware
  feature; whether another board implements the same setting is outside this test.
- **C — not measured:** data-loss safety, filesystem journaling behavior, UPS handoff,
  and recovery from a cut during a write. No number in this dataset speaks to those.

## Known traps

1. Cycle 1 has two rows. Use `record_status=CORRECTED_VALID` for cycle 1; the `COMPLETE_INVALID`
   row's `0` seconds is an artifact, not a fast recovery.
2. `boot_to_check_seconds` and `boot_to_container_start_seconds` are different intervals
   (boot → health check vs boot → container). The 40.36–40.97 s figure is the container one.
3. Cycle 1's boot-to-check (241.05 s) is much slower than cycles 2–3 (165.29 / 186.67 s).
   Three cycles is too small a sample to call this a stable "average boot time."
4. The MAC was logged only in cycle 3; do not treat the empty `mac` cells in cycles 1–2 as
   "no MAC" — they mean "not recorded by the script."
5. `PhoneVideo` is an evidence label, not a published file. The phone recordings were taken
   by the owner and are not in this repository.
6. The log timestamps carry a `-07:00` offset; the written conclusion quotes them in local
   wall-clock time. Do not mix the two without stating the offset.
7. All valid cycles used the same wired Ethernet interface and static-style address
   `192.168.5.22`; this dataset says nothing about Wi-Fi or DHCP re-acquisition latency.

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 AC Power-Restore (State After G3) Cycles*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_ac_restore_g3_cycles.csv`.
