# EQi12 QSV Concurrent-Transcode Telemetry — citable dataset

A row-per-sample record of the CPU and Intel GPU media-engine counters captured during two
concurrent 4K60 to 1080p60 Quick Sync transcode runs on one Beelink EQi12 (July 2026): one
run with **2 simultaneous streams** and one with **4**. It exists so a third party can plot
the saturation boundary themselves instead of taking a prose summary on trust.

- **File:** `dataset/EQi12_qsv_concurrent_samples.csv` (UTF-8, comma-separated, all fields quoted)
- **Version:** 1.0 — 2026-11-11
- **Rows:** 38 samples (17 two-stream + 21 four-stream), 10 columns
- **License:** [CC BY 4.0](../LICENSE) — use, chart, reanalyse, with attribution
- **Canonical URL:** https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_qsv_concurrent_samples.csv

## Why this file exists

The headline CSV gives the outcome (two streams stay real time; four do not). This file gives
the **telemetry behind it**: at two streams the GPU Video Decode counter sits around 70%,
while at four streams it pins at roughly 100% for the entire steady phase. That is the
observable signature of the media engine becoming the limit — useful to anyone comparing
i3-1215U-class hardware, and impossible to audit from a single summary number.

The values are copied verbatim from the raw capture. Two columns were added for citation
(`sample_id`, `raw_source_file`) and one factual flag column; **no numeric value was
recomputed, rounded or interpolated**. Ramp-up and wind-down samples (decode counter = 0)
are deliberately retained rather than trimmed, so any independent average can be reproduced
and so the sampling window is visible.

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 QSV Concurrent-Transcode Telemetry*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_qsv_concurrent_samples.csv`.
> CC BY 4.0. https://github.com/sohasteve-pixel/eqi12-measurement-data

BibTeX:

```bibtex
@misc{eqi12_qsv_concurrent_2026,
  author       = {{HomeLab Toolkit}},
  title        = {Beelink EQi12 QSV Concurrent-Transcode Telemetry (v1.0)},
  year         = {2026},
  howpublished = {\url{https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_qsv_concurrent_samples.csv}},
  note         = {CC BY 4.0}
}
```

## Field dictionary

| Column | Meaning |
|---|---|
| `sample_id` | Stable identifier `qsv_2stream_NN` / `qsv_4stream_NN`, numbered in capture order within each run. |
| `run_id` | `qsv_2stream` or `qsv_4stream` — group key for plotting the two runs separately. |
| `concurrent_streams` | Number of simultaneous ffmpeg QSV transcode processes in that run (`2` or `4`). |
| `timestamp_local_iso8601` | Local wall-clock timestamp of the sample, with the `-07:00` UTC offset as captured. **Not UTC.** |
| `elapsed_seconds` | Seconds since the start of that run, as recorded by the sampler. Resets to 0 at the four-stream run. |
| `cpu_percent` | Windows performance-counter CPU utilisation at that sample (whole system, not per process). |
| `gpu_video_decode_percent` | GPU Video Decode engine counter. See the over-100% trap below. |
| `gpu_video_encode_percent` | GPU Video Encode engine counter. All samples in this capture are `0`. |
| `sample_flags` | Factual flags derived only from the values in that row; `none` when no flag applies. |
| `raw_source_file` | Path to the verbatim source artifact in this repository. |

### Flag values

| Flag | Meaning |
|---|---|
| `decode_counter_zero_ramp_or_winddown` | Decode counter is 0 — start-up before workloads ramp, or the final wind-down sample. Exclude these before computing a steady-state average. |
| `decode_counter_over_100_sum_of_gpu_engines` | Counter exceeds 100 because several GPU engine counters are summed. Not an error and not a utilisation ceiling. |
| `encode_counter_nonzero` | Encode counter was non-zero. No such sample occurs in this capture; the flag is defined for future appended runs. |
| `none` | None of the above. |

## Evidence boundary (important)

| Class | Meaning | May appear here? |
|---|---|---|
| **A** | Directly measured on the tested Beelink EQi12, with raw data | Yes — this file is A-only telemetry |
| **B** | A component benchmark used for capacity reasoning, not an end-to-end result for a target application | No |
| **C** | Not measured | No — no value at all may be stated |

Consequences for anyone reusing this data:

- These counters describe **one tested configuration** (Beelink EQi12, Intel Core i3-1215U,
  16 GB DDR4-3200, WD PC SN540 512 GB NVMe, Windows 11 + Docker Desktop), one input file
  (H.264 3840x2160 60 fps, six losslessly concatenated 10-second clips) and one output
  setting (H.264 QSV 1920x1080 60 fps, 3600 frames per stream, null/throwaway output used
  to measure the transcode pipeline). They are **not** Jellyfin or Plex end-to-end streaming
  results and not a claim about other CPUs, drivers or operating systems.
- `gpu_video_encode_percent` being 0 throughout is a property of this ffmpeg pipeline, not
  evidence that the i3-1215U lacks hardware encode. Do not read it as a capability statement.
- The outcome (two streams at about 1.01x real time; four streams at about 0.708–0.710x,
  i.e. roughly 42–43 fps per stream) comes from the six ffmpeg logs, **not** from these
  counters. The counters show engine saturation; the logs show achieved frame rate. Cite both
  if you state a speed. See `codec/EQi12_QSV_2路与4路并发转码_校正结果.txt`.
- Sampling itself perturbs the measurement. A separate test on this same host found that
  polling `docker stats` in a tight loop inflated measured idle CPU; treat `cpu_percent`
  here as a coarse system-level indicator, not a precise per-process attribution.

## Known traps in the raw artifacts

1. **The original result file is wrong about pass/fail.** An early PowerShell
   `Start-Process` exit-code reading defect produced `Passed=0/x` and empty `ExitCodes`.
   The corrected judgement uses the six ffmpeg logs' 3600-frame completion, final speed and
   clean-end records. Do not use the initial result file as a success/failure source.
2. **Decode counter above 100%** (up to 101.34 in this capture) is the sum of multiple GPU
   engine counters, not a broken sensor and not a hard utilisation cap. 14 of the 38 samples
   carry this flag, all in the four-stream run.
3. **Two different time axes.** `elapsed_seconds` restarts at 0 for the four-stream run; use
   `run_id` plus `timestamp_local_iso8601` to place samples on a single timeline.
4. **Ramp and wind-down samples are retained** (decode = 0 at the first and last sample of
   the two-stream run, and the first sample of the four-stream run). Filtering them changes
   any computed average — state your filter when publishing one.
5. **Timestamps include a `-07:00` offset** and are local to the test session, not UTC.

## Reproducing / extending

- The capture script and the six per-stream ffmpeg logs sit in `codec/`. Run an equivalent
  test on your own hardware and open a PR with a comparison; leave the original artifacts
  untouched.
- This CSV is **append-only**: new runs may be appended with new `run_id` values and a
  version bump. Existing rows are never silently edited.
- The upstream source file `codec/EQi12_QSV_Concurrent_Samples.csv` is kept verbatim; if the
  two ever disagree, the upstream file is the raw evidence and this dataset should be
  corrected with an explicit note here.

## Version history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-11-11 | Initial release: 38 verbatim telemetry samples from the 2-stream and 4-stream QSV runs, with citation keys and factual flags. |
