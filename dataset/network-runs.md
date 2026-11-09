# EQi12 Network Transfer Runs — citable raw dataset

A row-per-run record of the 4 GiB memory-to-memory TCP transfers performed on one
Beelink EQi12 during the July 2026 network test campaign. Unlike the headline dataset,
this file keeps **both ends of every transfer** and **the runs that were thrown away**,
so a third party can reconstruct the conclusion instead of trusting it.

- **File:** `dataset/EQi12_network_transfer_runs.csv` (UTF-8, comma-separated, quoted fields)
- **Version:** 1.0 — 2026-11-10
- **Rows:** 12 runs, 14 columns
- **License:** [CC BY 4.0](../LICENSE) — use, chart, reanalyse, with attribution
- **Canonical URL:** https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_network_transfer_runs.csv

## Why this file exists

The headline dataset indexes one number per finding. This one indexes the **evidence
behind** the wired-vs-wireless finding: two physical gigabit ports, both directions,
local and peer timers, and an earlier Wi-Fi round that looked better but was invalidated
because the Ethernet cable's insertion time could not be proven. Keeping the invalid
rows with an explicit reason is the point. A dataset that only shows surviving runs
cannot be audited.

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 Network Transfer Runs*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_network_transfer_runs.csv`.
> CC BY 4.0. https://github.com/sohasteve-pixel/eqi12-measurement-data

BibTeX:

```bibtex
@misc{eqi12_network_runs_2026,
  author       = {{HomeLab Toolkit}},
  title        = {Beelink EQi12 Network Transfer Runs (v1.0)},
  year         = {2026},
  howpublished = {\url{https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_network_transfer_runs.csv}},
  note         = {CC BY 4.0; includes invalidated runs with reasons}
}
```

## Field dictionary

| Column | Meaning |
|---|---|
| `run_id` | Stable identifier. Safe as a join key across versions. |
| `date` | Local test date (America/Los_Angeles), `YYYY-MM-DD`. |
| `link_type` | `gigabit_ethernet` or `wifi_6_ax200`. |
| `adapter` | Windows adapter identity. The two physical RJ45 ports were mapped to distinct Realtek controllers by MAC. |
| `direction` | `EQi12_to_peer` or `peer_to_EQi12`. Server-sends vs server-receives are **not** interchangeable on Wi-Fi. |
| `role` | Whose timer/measurement the row records: `local_sender`, `local_receiver`, `peer_receiver`, `peer_sender`, `peer_timer`. |
| `bytes` | Payload size. All runs used 4294967296 bytes (4 GiB). |
| `seconds` | Elapsed wall time reported by that endpoint. |
| `throughput` | Rate as reported by that endpoint, without recomputation. |
| `throughput_unit` | `MiB/s` or `Mbps` exactly as the source artifact states. |
| `unit_convention` | `binary_1MiB` for every row. See the unit trap below. |
| `validity` | `valid` or `invalidated`. Filter on `valid` before computing a Wi-Fi conclusion. |
| `exclusion_reason` | Why an invalidated run was rejected. Empty for valid runs. |
| `source_file` | Path to the raw artifact inside this repository. |

## Unit trap (read before quoting)

The capture scripts divide by **1 MiB** and report "Mbps". Those numbers are not decimal
megabits per second. To convert, multiply by 1.048576: `870.08` binary Mbps becomes
about `912.35` decimal Mbit/s, and `897.58` becomes about `941.18`. The final Chinese
conclusion file states the decimal values explicitly; the per-endpoint raw files do not.
This CSV keeps the **original** values and marks the convention in every row — it does
not silently convert them. Do not mix decimal and binary figures in one chart.

## Evidence boundary

| Class | Meaning | May appear here? |
|---|---|---|
| **A** | Directly measured on the tested Beelink EQi12, with raw data | Yes — this file is A-only |
| **B** | A component benchmark used for capacity reasoning, not an end-to-end result | No |
| **C** | Not measured | No — no value at all may be stated |

Consequences for reuse:

- Every row describes **one tested configuration**: Beelink EQi12, Intel Core i3-1215U,
  16 GB DDR4-3200, WD PC SN540 512 GB, 2x Realtek GbE, Intel AX200, Windows 11,
  one wired peer at 192.168.5.8 through one router, July 2026.
- These are **memory-to-memory TCP transfers**, not SMB file copies, not disk-backed
  backups and not internet throughput. Do not quote them as "home server backup speed".
- The Wi-Fi rows are a **near-range, same-room, 5 GHz, channel 44, 160 MHz** result
  with RSSI about -23 dBm and both Ethernet adapters confirmed disconnected for the
  valid round. Through-wall Wi-Fi was deliberately not measured; no value is stated.
- The two `wifi_r1_near_*` rows are retained **only** as excluded evidence. Including
  them in a Wi-Fi average would reproduce a result the original test rejected.
- Local and peer timers for the same transfer are separate rows. They agree within
  0.01-0.05 s on the wired runs; that agreement is itself the integrity check.

## Reproducing / extending

- Raw logs and the PowerShell capture scripts sit in `network/`. Run them on your own
  hardware and open a PR with a comparison table; keep the original artifacts untouched.
- This CSV is **append-only**: add new `run_id` values and bump the version. Existing
  rows are never silently edited; corrections require an explicit note here.
- Filenames containing Chinese lab names are kept verbatim so artifacts remain traceable
  to the original test session.

## Version history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-11-10 | Initial release: 12 runs (10 valid, 2 invalidated) across two wired ports and one Wi-Fi 6 adapter, both directions, with local and peer timers. |
