# Monitoring-poll overhead: field dictionary and known traps (v1.0)

**CSV:** [`EQi12_monitoring_poll_overhead_samples.csv`](EQi12_monitoring_poll_overhead_samples.csv)
**License:** CC BY 4.0 · **Append-only** · **Published:** 2026-11-19

## What this is

Two 60-sample idle-resource captures of the same Beelink EQi12 on the same morning
(2026-07-13, UTC−07:00 timestamps), taken ~11 minutes apart. The only meaningful
difference between them is **how the monitoring loop itself worked**:

- **Run A (`A_polling`):** the sampling loop read CPU and memory counters, then called
  `docker stats` for all four containers on *every* sample, then slept to the next 5 s tick.
- **Run B (`B_low_overhead`):** one batched Windows performance-counter request per sample;
  container state was captured once before and once after, not inside the loop.

Both runs are verbatim copies of
`power/EQi12_SSDIdle_02_IDLE_SAMPLES_5MIN.csv` and
`power/EQi12_SSDIdle_04_LOW_OVERHEAD_IDLE_5MIN.csv` with a `run_id`, `test_group`,
`memory_metric` label and `source_file` column added for citation. No sample was
dropped and no value was recalculated. The `docker_detail_verbatim` column carries
Run A's raw `docker stats` string unchanged (semicolon-separated containers); it is
empty for Run B because that run did not poll Docker per sample.

Headline result (from the two accompanying summary TXT files, not recomputed here):
CPU average **21.88%** (Run A) vs **16.87%** (Run B) = **+5.00 percentage points,
+29.7% relative**; CPU standard deviation 7.32 vs 2.0. Run A's own sampling interval
stretched from the intended 5 s to about 9.2 s.

## Citation

> sohasteve-pixel (2026). *EQi12 monitoring-poll overhead: two 60-sample idle captures,
> per-sample docker stats polling vs a batched counter request.* CC BY 4.0.
> https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_monitoring_poll_overhead_samples.csv

## Fields (9 columns, all values quoted)

| Field | Meaning |
|---|---|
| `run_id` | `A_polling` or `B_low_overhead` |
| `test_group` | `same_host_same_morning` — always; marks the two runs as a matched pair |
| `sample_index` | 1–60 within each run |
| `time_iso` | Verbatim sample timestamp with original UTC−07:00 offset |
| `cpu_percent_verbatim` | CPU percent exactly as logged, including decimals |
| `memory_metric` | **Which** memory quantity the next column holds — differs by run, see traps |
| `memory_mb_verbatim` | Verbatim MB value; meaning depends on `memory_metric` |
| `docker_detail_verbatim` | Run A only: raw per-container `docker stats` string; empty for Run B |
| `source_file` | Original path under `power/` for provenance |

## Known traps (read before citing)

1. **The two runs record different memory quantities.** Run A logs *used* memory
   (`UsedMemoryMB`, ~10,232 MB avg); Run B logs *available* memory (`AvailableMemoryMB`,
   ~5,869 MB avg). Never compute a memory "difference" between runs — on this 16 GB
   machine 10.2 GB used and 5.8 GB available are consistent descriptions of the same state.
2. **Do not treat this as a clean-boot OS idle measurement.** Windows, Codex and other
   resident desktop applications remained open. It is an unattended background-state
   sample; the conclusion is about *relative* polling cost, not absolute idle CPU.
3. **Run A's sample interval is not 5 s.** The loop stretched to ~9.2 s per sample because
   `docker stats` consumed part of each tick. Timestamps are verbatim — use them, not an
   assumed fixed cadence, for any time-based analysis.
4. **Four containers, one memory ceiling.** Every Run A container line reports
   `/ 7.638GiB` — that is the WSL2/Docker container ceiling on this host, not total RAM.
   The ceiling is corroborated by the separate WSL2 baseline capture under `wsl/`.
5. **CPU is a sampled Windows counter, not a wall-power measurement.** Wall draw for the
   same host lives in `power/` (12 W idle, 13 W QSV transcode, 37 W sustained CPU).
   Do not convert these CPU percentages into watts.
6. **This is not a benchmark of any monitoring product.** The test compares *polling
   methods*. Beszel, Netdata, Prometheus and Grafana were not installed or measured.
   Any footprint claim for those tools is a vendor statement, not data from this file.
7. **Verbatim values include resolution differences.** Run A CPU values have two
   decimals, container MiB strings mix `146MiB` and `145.6MiB`; preserve as-is.

## Related

- Article: https://homelabtoolkit.com/lab/docker-stats-monitoring-overhead-mini-pc/
- Comparison article: https://homelabtoolkit.com/compare/beszel-vs-netdata-vs-prometheus-mini-pc/
- Other citable datasets: [`dataset/README.md`](README.md)
