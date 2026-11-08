# EQi12 Headline Measurements — citable dataset

A flat, machine-readable index of the headline measurements from the Beelink EQi12
home-server test campaign (July 2026). Every row points at the raw artifact it came from,
so a third party can quote a number **and** verify it without reading the website.

- **File:** `dataset/EQi12_headline_measurements.csv` (UTF-8, comma-separated, quoted fields)
- **Version:** 1.0 — 2026-11-09
- **Rows:** 43 measurements, 8 columns
- **License:** [CC BY 4.0](../LICENSE) — use, chart, reanalyse, with attribution
- **Canonical URL:** https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_headline_measurements.csv

## Why this file exists

The raw artifacts in this repository are logs, transcripts and per-test CSVs in mixed
languages and formats. That is correct for evidence, but awkward to cite. This file is the
**quotable layer**: one row per number, with its units, test conditions, evidence class,
source artifact and the published page that explains the method.

It deliberately contains **only measurements** (evidence class A). No derived estimates,
no modelled runtimes, no third-party device figures and no application-level claims.

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 Headline Measurements*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_headline_measurements.csv`.
> CC BY 4.0. https://github.com/sohasteve-pixel/eqi12-measurement-data

BibTeX:

```bibtex
@misc{eqi12_headline_2026,
  author       = {{HomeLab Toolkit}},
  title        = {Beelink EQi12 Headline Measurements (v1.0)},
  year         = {2026},
  howpublished = {\url{https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_headline_measurements.csv}},
  note         = {CC BY 4.0}
}
```

## Field dictionary

| Column | Meaning |
|---|---|
| `metric_id` | Stable dot-separated identifier. Safe to use as a join key across versions. |
| `metric` | Human-readable description of what was measured. |
| `value` | Numeric value. No rounding beyond what the source artifact reports. |
| `unit` | `W`, `MiB/s`, `Mbit/s`, `RPS`, `TPS`, `ops/s`, `MB`, `s`, `hours`, `percent`, `count`, `of 5 cycles`, `x realtime`, `boolean`. |
| `conditions` | The test setup that makes the value meaningful. **Quote this alongside the number.** |
| `evidence_class` | Always `A` = directly measured on the tested EQi12. See boundary below. |
| `source_file` | Path to the raw artifact inside this repository. |
| `website_page` | Site path with the full method, caveats and figures. |

## Evidence boundary (important)

These three classes are used across the project and are **not interchangeable**:

| Class | Meaning | May appear here? |
|---|---|---|
| **A** | Directly measured on the tested Beelink EQi12, with raw data | Yes — this file is A-only |
| **B** | A component benchmark (e.g. PostgreSQL, Redis) used for capacity reasoning, **not** an end-to-end result for a target application | No |
| **C** | Not measured | No — no value at all may be stated |

Consequences for anyone reusing this data:

- Every number describes **one tested configuration** (Beelink EQi12, Intel Core i3-1215U,
  16 GB DDR4-3200, WD PC SN540 512 GB NVMe, 2x Realtek GbE, Intel AX200, Windows 11 +
  WSL2/Docker Desktop). It is not a claim about other mini PCs, other N100/i3 variants or
  other operating systems.
- `docker.*` rows are **localhost synthetic benchmarks**. They exclude internet latency,
  TLS, authentication, sessions and application logic. They describe the tested host and
  stack, not production web-application throughput.
- `codec.*` rows are ffmpeg/QSV pipeline results, not Jellyfin end-to-end streaming counts.
- `power.*` rows are wall-meter readings with resident desktop applications open; short
  background activity can move them by a few watts.
- `network.wifi_*` is a near-range, 5 GHz, same-room result (RSSI about -23 dBm).
  Through-wall Wi-Fi was intentionally **not** measured and no value is stated for it.

## Known traps in the raw artifacts

Cite this file rather than guessing from a log:

1. **nginx RPS:** `docker/EQi12_DockerWebStack_05_FINAL_RESULT.txt` contains an early
   synchronous-client run (4892.31 / 1.75 / 3.67 RPS) that is **invalid**. The corrected
   asynchronous-client results are in `docker/EQi12_DockerWebStack_01_NGINX_HTTP_FIXED_RESULTS.csv`
   and are the values indexed here.
2. **Codec matrix:** an earlier 0.03-second all-fail run was a script argument error,
   retained as `INVALID_FIRST`. Only the valid corrected run is indexed.
3. **Wi-Fi:** an earlier 879.35 / 904.32 Mbps round is marked invalid because the Ethernet
   cable was inserted at an ambiguous time. Only 618.37 / 870.18 Mbps is indexed.
4. **AV1 encode:** unsupported on this i3-1215U (driver exit -40). Indexed as `0` (boolean),
   not as a speed.
5. **S.M.A.R.T. temperature:** access to Storage Reliability Counter was denied during the
   NVMe baseline; no temperature value exists in that artifact. Do not infer one.
6. **Docker polling overhead:** the per-sample `docker stats` run inflated measured idle CPU.
   The low-overhead single-counter sample is what `docker.low_overhead_*` indexes.

## Reproducing / extending

- Test scripts (`*.ps1`, `*.py`) sit next to their logs. Run them on your own hardware and
  open a PR with a comparison table; keep the original artifacts untouched.
- This CSV is **append-only**: new rows may be added with new `metric_id` values and a version
  bump. Existing rows are corrected only with an explicit note here, never silently edited.
- Filenames containing Chinese lab names are kept verbatim so artifacts remain traceable to
  the original test session.

## Version history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-11-09 | Initial release: 43 A-class measurements across power, storage, network, stability, Docker and QSV codec categories. |
