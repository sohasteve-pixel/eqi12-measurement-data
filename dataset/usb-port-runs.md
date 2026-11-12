# EQi12 USB Port Throughput Runs — citable dataset

A row-per-run record of the "one USB-A port is much slower than the others" finding on a
Beelink EQi12: **the same EAGET SSD 1TB, the same cable and the same 50 GiB deterministic test
file were moved across four physical connectors; three ports wrote at ~301 MiB/s and the
rear-leftmost port at ~36 MiB/s.** Every value is copied verbatim from the raw artifacts in
`storage/`, including the awkward ones.

This is the quotable layer for a claim that is easy to misquote. Read the traps below before
charting it.

- **File:** `dataset/EQi12_usb_port_throughput_runs.csv` (UTF-8, comma-separated, all fields quoted)
- **Version:** 1.0 — 2026-11-13
- **Rows:** 8 runs, 19 columns, in three `test_group` partitions
- **Test bed:** Beelink EQi12, Intel Core i3-1215U, 16 GB RAM, Windows 11 (July 2026)
- **License:** [CC BY 4.0](../LICENSE) — use, chart, reanalyse, with attribution
- **Canonical URL:** https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_usb_port_throughput_runs.csv

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 USB Port Throughput Runs*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_usb_port_throughput_runs.csv`.
> CC BY 4.0. https://github.com/sohasteve-pixel/eqi12-measurement-data

BibTeX:

```bibtex
@misc{eqi12_usb_ports_2026,
  author       = {{HomeLab Toolkit}},
  title        = {Beelink EQi12 USB Port Throughput Runs (v1.0)},
  year         = {2026},
  howpublished = {\url{https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_usb_port_throughput_runs.csv}},
  note         = {CC BY 4.0}
}
```

## What the three groups are (do not mix them)

| `test_group` | Rows | Payload | Date | Purpose |
|---|---|---|---|---|
| `four_port_50GiB` | 4 | 50 GiB (`53687091200` bytes) | 2026-07-11 | The actual port comparison. Only these 4 rows are apples-to-apples. |
| `slow_port_retest_4GiB` | 3 | 4 GiB (`4294967296` bytes) | 2026-07-13 | Independent retest of the slow port two days later, to show it is consistently slow. |
| `front_control_1GiB` | 1 | 1 GiB (`1073741824` bytes) | 2026-07-12 | Write-only control on the front port, with a durable-flush breakdown. No readback. |

**Only compare `write_mibps` within `four_port_50GiB`.** Combining the 4 GiB and 1 GiB runs
into the same average is the most likely way to misquote this file: payload size, day, and
objective all differ.

## Field dictionary

| Column | Meaning |
|---|---|
| `run_id` | Stable identifier (`PORT50-R1..R4`, `RETEST-R1..R3`, `CONTROL-1G-F1`). Safe join key. |
| `test_group` | Partition; see table above. **Always filter on this first.** |
| `test_date_local` | Local calendar date of the capture (`America/Los_Angeles`, UTC-07:00). |
| `capture_timestamp` | Timestamp as printed in the raw artifact; `NA` where the artifact gives only a date. |
| `physical_connector` | Physical port label as written in the raw artifact (verbatim). |
| `connector_label_zh` | Original Chinese lab label, kept for traceability to the test session. |
| `payload_bytes` | Exact byte count. Binary units: `53687091200` = 50 GiB, not 50 GB. |
| `payload_label` | Human-readable binary-unit label. |
| `write_seconds` | Wall seconds for the write. For `PORT50-R1` this is a **conservative two-segment wall span**, see trap 2. |
| `write_mibps` | Write rate in MiB/s as reported by the raw artifact. No recomputation. |
| `readback_seconds` | Seconds for the unbuffered readback copy to internal NVMe. |
| `readback_mibps` | Unbuffered readback rate in MiB/s as reported. |
| `sha256_source` / `sha256_readback` | Full-file hashes of the deterministic source and the readback. Equal on every run with a hash. |
| `hash_match` | `TRUE`/`True` as printed; `NA` for the write-only control. |
| `robocopy_exit_code` | Exit code as printed. **`1` is robocopy success**, see trap 4. |
| `disk_health` | Physical disk / volume health as printed; `NA` where not captured. |
| `method_note` | Per-run caveats. **Quote alongside the number.** |
| `source_file` | Path to the raw artifact inside this repository. |

## Known traps

1. **The 50 GiB and 4 GiB files have different SHA256 values.** `PORT50-*` all share
   `10B919C7…1590`; `RETEST-*` all share `25030DF2…CB12`. They are different deterministic
   payloads on different days. A mismatch between groups is expected, not corruption.
2. **`PORT50-R1` write is not a clean single-pass transfer.** The controller process hit its
   execution-time limit, so the 50 GiB write finished in two segments spanning 05:54:18 to
   06:17:46. `write_mibps = 36.36` is the *conservative wall-time rate including the
   interruption*, not a steady-state throughput. It still reproduces: the three independent
   4 GiB rounds on the same port two days later all landed at 39.35–39.75 MiB/s.
3. **Three different read operations are easy to conflate.** The `readback_*` columns are the
   unbuffered copy from external SSD to internal NVMe (42.06 MiB/s on the slow port, ~432 MiB/s
   on the others). A *separate* external-drive full-file read for SHA256 took 1465.79 s at
   ~34.93 MiB/s on the slow port; it is deliberately not in these columns. `DHashSeconds` and
   `CHashSeconds` in the raw artifacts are hash-computation times, not transfer times.
4. **`RobocopyExitCode: 1` means success** (files were copied). Do not read it as a failure code.
   The consolidated slow-port artifact reports "Robocopy: 0 failed, 0 mismatch".
5. **Do not infer a USB generation from throughput.** The measured path is the *complete attached
   path* — EQi12 port + cable + USB enclosure/SSD. The raw scope note explicitly says not to
   attribute the slow result to the port alone without repeating with a known-fast cable and
   enclosure and recording the negotiated USB speed.
6. **The 1 GiB control filename mentions USB-C, but no USB-C measurement is in that artifact.**
   `storage/EQi12_USB-C_vs_FrontUSB-A_1GiB_Control.txt` contains only the Front USB-A control
   row. This dataset asserts no USB-C number. Its `write_seconds = 3.544` includes a 0.118 s
   durable flush; the write-calls-only rate was 298.91 MiB/s over 3.426 s.
7. **Timestamps are UTC-07:00 local, not UTC.** Retest transcript start `20260713042430` is a
   PowerShell transcript stamp, not a per-round start time; all three retest rounds share it.

## Evidence boundary (A / B / C)

These three classes are used across the project and are **not interchangeable**:

| Class | Meaning | May appear here? |
|---|---|---|
| **A** | Directly measured on the tested Beelink EQi12, with raw data | Yes — this file is A-only |
| **B** | Component-level benchmark (e.g. a vendor SSD spec) | No — never relabel as a measured result of this machine |
| **C** | Not measured (third-party reports, estimates, models) | No — no number at all |

Every row is an A-class measurement of **this one EQi12 with this one SSD and cable**. The
finding is reproducible on this unit; it is not a claim about all EQi12 units, all USB
enclosures, or mini PCs in general. No application-level performance is inferred from the
transfer rates.

## Source artifacts

| Group | Raw file(s) |
|---|---|
| `four_port_50GiB` | `storage/EQi12_USB_SSD_50GiB_Consolidated_Result.txt`, `storage/EQi12_USB_SSD_Port2_50GiB_Result.txt`, `storage/EQi12_USB_SSD_RearLeft3_50GiB_Result.txt`, `storage/EQi12_USB_SSD_Front_50GiB_Result.txt`, `storage/EQi12_USB_四接口50GiB最终对照.txt` |
| `slow_port_retest_4GiB` | `storage/EQi12_USB_SlowPort_3Rounds.csv`, `storage/EQi12_USB_SlowPort_3Rounds_Result.txt`, `storage/EQi12_USB_SlowPort_3Rounds_Raw.log` |
| `front_control_1GiB` | `storage/EQi12_USB-C_vs_FrontUSB-A_1GiB_Control.txt` |

Append-only: corrections are added as new rows or new versions, never by editing existing
values.
