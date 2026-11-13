# EQi12 Wake-on-LAN Power-State Cycles — citable dataset

Row-per-cycle record of the two Wake-on-LAN five-cycle tests run on the Beelink EQi12
on 2026-07-12: WOL from full shutdown (S5) and WOL from sleep (S3). Every value is copied
verbatim from the raw script logs and the Windows event export; no values are averaged,
rounded or reconstructed.

- **File:** `dataset/EQi12_wol_power_state_cycles.csv` (UTF-8, comma-separated, all fields quoted)
- **Version:** 1.0 — 2026-11-14
- **Rows:** 10 cycles, 24 columns (5 × `S5_WOL` + 5 × `S3_WOL`)
- **License:** [CC BY 4.0](../LICENSE) — use, chart, reanalyse, with attribution
- **Canonical URL:** https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_wol_power_state_cycles.csv

## Why this file exists

The S3 script log reports `RECOVERY` for **all five** cycles. Read on its own, it looks like
a clean 5/5 WOL success from sleep. It is not. Cross-referencing the Windows
Power-Troubleshooter event log shows cycle 5 was woken by the **Power Button** about
4 m 50 s after sleep, not by a magic packet. The published result is therefore **4/5 for S3**
and **5/5 for S5**. This CSV puts the two sources side by side per cycle so a third party
can audit that conclusion instead of trusting a summary — including the row that looks bad.

The retained failure is the point: a wake method that works four times quickly and once
only after someone presses the power button is not reliable enough for unattended
scheduling (backup windows, off-peak jobs), even though the raw pass count is 10/10.

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 Wake-on-LAN Power-State Cycles*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_wol_power_state_cycles.csv`.
> CC BY 4.0. https://github.com/sohasteve-pixel/eqi12-measurement-data

```bibtex
@misc{eqi12_wol_cycles_2026,
  author       = {{HomeLab Toolkit}},
  title        = {Beelink EQi12 Wake-on-LAN Power-State Cycles (v1.0)},
  year         = {2026},
  howpublished = {\url{https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_wol_power_state_cycles.csv}},
  note         = {CC BY 4.0. 5 S5 cycles, 5 S3 cycles, wake sources cross-checked against Windows Power-Troubleshooter events.}
}
```

## Field dictionary

| Column | Meaning |
|---|---|
| `test_group` | Partition key: `S5_WOL` (full shutdown, cold boot) or `S3_WOL` (suspend to RAM). **Do not average columns across groups** — S5 and S3 are different physical processes with different timing fields. |
| `cycle` | Cycle number 1–5 within its own `test_group`. |
| `power_state` | Verbatim description of the state under test. |
| `script_verdict` | Verbatim verdict from the raw script log: `PASS` (S5) or `RECOVERY` (S3). **This is a health check, not a WOL attribution** — see trap 1. |
| `wol_attributed` | `TRUE` if the wake was caused by a magic packet, `FALSE` otherwise. Derived by cross-checking the Windows event log, not by the script. Empty for S5 where the attribution rests on the peer packet log + phone video (see trap 4). |
| `wake_source_event` | Verbatim `Wake Source:` value from Windows Power-Troubleshooter event id 1. Empty for S5 (no event-log wake source exists for full shutdown). |
| `boot_time_local` | S5: verbatim `Boot=` timestamp, `-07:00` offset. |
| `check_time_local` | S5: verbatim `Check=` timestamp, `-07:00` offset. |
| `pre_sleep_time_local` | S3: verbatim `PRE_SLEEP` timestamp, `-07:00` offset. |
| `resumed_time_local` | S3: verbatim `RESUMED` timestamp, `-07:00` offset. |
| `sleep_time_utc_event` | S3: verbatim `Sleep Time:` from Windows event 1. Labelled `Z` in the source. |
| `wake_time_utc_event` | S3: verbatim `Wake Time:` from Windows event 1. Labelled `Z` in the source. |
| `network_check` | Verbatim network result: `Network=PASS` (S5) / `Ethernet=Up` (S3). |
| `interface` | Verbatim interface name (`Ethernet`). |
| `ipv4` | Verbatim LAN address (`192.168.5.22`). |
| `jellyfin_check` | Verbatim Jellyfin result: `JellyfinHTTP=200` (S5) / `Jellyfin=eqi12-jellyfin` container name (S3). Not the same measurement. |
| `container_start_seconds` | S5 only: verbatim `ContainerStartSeconds`, seconds for the Jellyfin container to come up after boot. |
| `network_recovery_seconds` | S3 only: verbatim `NetworkSeconds`, seconds for Ethernet/IPv4 to recover after resume. |
| `docker_recovery_seconds` | S3 only: verbatim `DockerSeconds`, seconds for the container to recover after resume. |
| `sleepcall` | S3 only: verbatim `SleepCall=True`. |
| `lastwake` | S5 only: verbatim `LastWake=` field. Unreliable for S5; kept for traceability, see trap 4. |
| `evidence` | What the attribution rests on: `PhoneVideo+PeerSender` (S5) / `WindowsEventLog+ScriptLog` (S3). |
| `source_logs` | Paths to the raw artifacts inside this repository. |
| `notes` | Per-cycle caveats, verbatim context and the critical S3 cycle-5 finding. |

Empty cells mean the column does not apply to that `test_group` — not a missing measurement.

## Evidence boundary (A / B / C)

| Class | Meaning | May appear here? |
|---|---|---|
| **A** | Directly measured on the tested Beelink EQi12, with raw data | Yes — all numeric and boolean values are verbatim from the raw logs/events |
| **B** | A component benchmark used for capacity reasoning, not an end-to-end result | No |
| **C** | Not measured | No — no value at all is stated for unmeasured things |

Scope limits for reuse:

- All values describe **one tested configuration** (Beelink EQi12, Intel Core i3-1215U,
  16 GB DDR4-3200, WD PC SN540 512 GB NVMe, 2× Realtek GbE, Intel AX200, Windows 11).
  They are not claims about other mini PCs, NICs or operating systems.
- `wol_attributed` is an **attribution from event evidence**, not a probability. 4/5 is a
  count over five cycles, not an 80% success rate. No reliability estimate is stated.
- No through-wall, WAN, IPv6, or "magic packet over Wi-Fi" behaviour was measured. Nothing
  here says anything about those paths.
- The peer sender, network switch and BIOS wake settings are described in the S5 conclusion
  file; they are not independently varied in this dataset.

## Known traps in the raw artifacts

1. **Script `RECOVERY` ≠ WOL success (the important one).** The S3 script verifies
   Ethernet is up, IPv4 is present, Jellyfin is reachable and the container is healthy. It
   never reads the wake source. Cycle 5 passes every one of those checks — after a human
   pressed the power button. Anyone using only `network/EQi12_S3_WOL_5cycles.log` will
   conclude 5/5. The `wake_source_event` column is the correction.
2. **Cycle 5 latency is the tell.** Sleep 13:12:43Z → wake 13:17:33Z ≈ 4 m 50 s, while
   cycles 2–4 are ≈ 28 s. The `resumed_time_local` gap (06:12:40 → 06:17:33) shows the same
   thing in local time. Do not "clean" this outlier.
3. **Cycle 1 is not steady state.** S3 cycle 1 sleep-to-wake is ≈ 65 s vs ≈ 28 s for cycles
   2–4 (first cycle of the session, setup overhead). Do not quote it as the typical resume
   latency, and do not average it with cycle 5.
4. **`/lastwake` is useless for S5.** For a full shutdown Windows reports
   `Wake History Count - 0` / `S5_NotReported`. WOL attribution for S5 rests on the peer's
   continuous UDP 7/9 magic-packet send log plus five phone videos, not on `powercfg`.
   The `lastwake` column is kept verbatim so this limitation is visible.
5. **Two different clock labels.** Script logs carry a `-07:00` offset; Windows event
   `TimeCreated` is local time while `Sleep Time` / `Wake Time` are labelled `Z`. Compare
   within a source, or convert deliberately — do not subtract a local script timestamp from
   a `Z` event timestamp directly.
6. **`container_start_seconds` is not boot time.** It measures how long the Jellyfin
   container took to come up, not time-from-power-on-to-usable. Likewise
   `network_recovery_seconds` / `docker_recovery_seconds` are post-resume recovery, not
   wake latency.
7. **`jellyfin_check` is not one metric.** S5 records an HTTP 200; S3 records the container
   name. They are copied verbatim and must not be compared as pass/fail rates.
8. **Do not drop the `FALSE` row.** Published pages stating "5/5 shutdown WOL, 4/5 sleep
   wake" refer to `wol_attributed`, not `script_verdict`. The tenth row is why the two
   numbers differ.

## Related published pages

- [WOL works from shutdown but fails from sleep](https://homelabtoolkit.com/fix/wake-on-lan-shutdown-works-sleep-fails/)
- [S5 / PME / RTC wake sources](https://homelabtoolkit.com/fix/acpi-s5-wake-sources-pme-rtc-wol/)
- [USB and network devices missing after sleep](https://homelabtoolkit.com/fix/usb-nic-dropout-after-sleep-mini-pc/)
- [Wake-on-LAN not working: 12 causes](https://homelabtoolkit.com/fix/wake-on-lan-not-working-causes/)

## Version history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-11-14 | Initial release: 10 verbatim cycles across S5 and S3, with per-cycle wake-source attribution from the Windows event log. Append-only. |
