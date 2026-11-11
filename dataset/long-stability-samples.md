# EQi12 12.57-Hour Stability Telemetry — citable dataset

A row-per-sample record of the overnight Docker home-server stability run on one Beelink
EQi12 (July 2026): 150 samples taken roughly every five minutes for 12.57 hours, with the
HTTP check, container health/running counts, restart total, sampled CPU, available memory
and disk/network byte rates. It exists so a third party can plot the run themselves — and
see exactly what "zero failures" did and did not cover — instead of taking a summary on trust.

- **File:** `dataset/EQi12_long_stability_samples.csv` (UTF-8, comma-separated, all fields quoted)
- **Version:** 1.0 — 2026-11-12
- **Rows:** 150 samples, 15 columns
- **License:** [CC BY 4.0](../LICENSE) — use, chart, reanalyse, with attribution
- **Canonical URL:** https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_long_stability_samples.csv
- **Verbatim source:** [`power/EQi12_Overnight_24h_Samples.csv`](../power/EQi12_Overnight_24h_Samples.csv)
- **Prose summary:** [`stability/EQi12_LongStability_12h57_Summary.txt`](../stability/EQi12_LongStability_12h57_Summary.txt)

## Why this file exists

The headline CSV records the outcome as one row: *12.57-hour monitored run, zero HTTP
failures, zero container restarts*. A single row cannot show the shape of the run. This file
gives the telemetry behind it: every five-minute sample, with the monitor's own success
criteria visible in the `HttpStatus`, `DockerHealthy`, `DockerRunning` and `RestartTotal`
columns. Anyone can recompute the zero-failure claim, draw the CPU and memory envelope, or
check whether a disk-write spike coincided with a bad sample.

**The values are copied verbatim from the raw capture.** Two columns were added for citation
(`sample_id`, `raw_source_file`). No numeric value was recomputed, rounded, interpolated or
filled; no sample was trimmed. The final `Error` column is empty on all 150 rows, exactly as
in the source, and is retained rather than dropped so the schema matches the original file.

Observed range across the 150 rows (arithmetic over the published rows, not new measurements):

| Column | Observed |
|---|---|
| `ElapsedMinutes` | 0.0 → 754.1 |
| `HttpStatus` | 200 on all 150 samples |
| `DockerHealthy` / `DockerRunning` | 3 / 3 on all 150 samples |
| `RestartTotal` | 0 on all 150 samples |
| `CpuPercent` | 0 – 52 |
| `AvailableMB` | 5472 – 6911 |
| `DiskWriteBps` | peak 2,208,860 |
| `Error` | empty on all 150 samples |

## Field dictionary

| Column | Unit / type | Meaning |
|---|---|---|
| `sample_id` | string | Stable citation key, `STAB-001` … `STAB-150`, in source order. Added for citation only. |
| `raw_source_file` | string | Repository-relative path of the verbatim source artifact. Added for citation only. |
| `Timestamp` | ISO 8601 with offset | Local wall-clock time of the sample, with a `-07:00` offset. **Not UTC.** |
| `ElapsedMinutes` | minutes (decimal) | Minutes since the first sample; 754.1 ≈ 12.57 h. |
| `HttpStatus` | HTTP code | Result of the monitor's HTTP probe against the web stack. |
| `DockerHealthy` | count | Containers reporting healthy at that sample. |
| `DockerRunning` | count | Containers running at that sample. |
| `RestartTotal` | count | Combined container restart count at that sample. |
| `CpuPercent` | percent | **Instantaneous sampled** CPU, not an average over the interval. |
| `AvailableMB` | MiB (as labelled in source) | Available memory, not used memory. Do not subtract from 16384 to get a container footprint. |
| `DiskReadBps` | bytes/second | Instantaneous sampled disk read rate; many zeros are real zero-read samples, not missing data. |
| `DiskWriteBps` | bytes/second | Instantaneous sampled disk write rate; spikes are point samples, not totals. |
| `NetRecvBps` / `NetSendBps` | bytes/second | Instantaneous sampled network rates. |
| `Error` | string | Monitor error text; empty on every row of this run. |

## Known traps in the raw artifacts

1. **The offset is `-07:00`, not UTC.** Converting these timestamps to UTC shifts the run by
   seven hours. Keep the offset when plotting against wall-clock events.
2. **"Zero failures" is scoped to the monitor's checks.** The companion Windows event summary
   in `stability/EQi12_Event_Summary_24h.txt` reports 4 system and 28 application
   warning/error/critical events in the same 24-hour window (including a DistributedCOM
   10016 and a third-party updater service failure). Those events did not fail the HTTP
   probe or restart a container, but they are not absent. A clean HTTP/container row is
   **not** a claim that the OS event log was clean.
3. **Column positions matter.** `Error` is the 13th column of the source (15th here, after
   the two citation columns). Splitting on commas without a quoted-field parser makes
   `NetSendBps` look like the error column. Use a real CSV parser.
4. **The run was stopped early by request**, after crossing a 12-hour minimum — it is not a
   full 24-hour run despite the source filename containing `24h`. The observed span is
   754.1 minutes.
5. **Sampling is sparse (~5 min).** A failure and recovery between two samples would be
   invisible. This dataset supports "no failure observed at any sample", not "no failure
   occurred".
6. **Sampled CPU has an observer effect.** On this same host, tight `docker stats` polling
   inflated measured idle CPU by 29.7% (see `docker/EQi12_DockerWebStack_*`). Treat
   `CpuPercent` as the monitor's reading, not a clean baseline.

## Evidence boundary (A / B / C)

- **A — directly measured:** every value in this CSV is a recorded sample from the EQi12
  test host under the Windows + Docker Desktop stack described in the repository README.
- **B — component-level:** derived averages, envelopes or annualised power computed from
  these rows are arithmetic, not measurements. Label them as derived.
- **C — not measured:** no smart home hub, media application, NAS OS or reverse proxy was
  benchmarked in this run. These numbers describe the host and its four monitored
  containers only; they must not be presented as an application's footprint or uptime.
- The machine under test is a **Beelink EQi12** with an Intel Core i3-1215U (6C/8T),
  16 GB DDR4-3200, a 512 GB WD PC SN540 NVMe, two Realtek gigabit ports and an Intel AX200.

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 12.57-Hour Stability Telemetry*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_long_stability_samples.csv`.
> CC BY 4.0. https://github.com/sohasteve-pixel/eqi12-measurement-data

BibTeX:

```bibtex
@misc{eqi12_long_stability_2026,
  author       = {{HomeLab Toolkit}},
  title        = {Beelink EQi12 12.57-Hour Stability Telemetry (v1.0)},
  year         = {2026},
  howpublished = {\url{https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_long_stability_samples.csv}},
  note         = {150 verbatim samples, CC BY 4.0}
}
```

## Version history

- **1.0 (2026-11-12):** initial release. 150 rows copied verbatim from
  `power/EQi12_Overnight_24h_Samples.csv`; added `sample_id` and `raw_source_file` for
  citation. Append-only — later corrections will be added as new rows or a new version,
  never by editing values in place.
