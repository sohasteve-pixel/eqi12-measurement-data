# Browser 4K60 GPU-decode samples — field dictionary & citation

**Dataset:** [`EQi12_browser_4k60_decode_samples.csv`](EQi12_browser_4k60_decode_samples.csv)
**Version:** 1.0 — 2026-11-20 · **38 data rows × 13 columns** · **License:** [CC BY 4.0](../LICENSE)
**Hardware:** the tested Beelink EQi12 (Intel Core i3-1215U, 16 GB DDR4-3200, Windows 11),
Microsoft Edge. All values are **evidence class A** (directly captured on the tested unit).

## Why this file exists

Browser playback is the most common real home-server media workload, but it is rarely
published with the raw GPU counter trace. This file gives the **per-second Video Decode
utilization samples** for two playback cases plus run-level summaries, so a third party can
check the "4K60 plays in hardware with no dropped frames" claim rather than trust a screenshot.
It is the raw sampling layer behind the site's
[4K60 YouTube browser playback test](https://homelabtoolkit.com/lab/mini-pc-4k60-youtube-browser-playback/).

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 Browser 4K60 GPU-Decode Samples*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_browser_4k60_decode_samples.csv`. CC BY 4.0.
> https://github.com/sohasteve-pixel/eqi12-measurement-data

```bibtex
@misc{eqi12_browser_4k60_2026,
  author       = {{HomeLab Toolkit}},
  title        = {Beelink EQi12 Browser 4K60 GPU-Decode Samples (v1.0)},
  year         = {2026},
  howpublished = {\url{https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_browser_4k60_decode_samples.csv}},
  note         = {CC BY 4.0}
}
```

## Field dictionary

| Column | Meaning |
|---|---|
| `run_id` | Stable partition key. Groups rows into one capture session. Safe join key. |
| `record_type` | `per_sample` = one GPU counter reading; `run_summary` = run-level aggregate from the source log. |
| `sample_index` | 1-based sample order within `per_sample` runs; blank for summaries. |
| `timestamp_local` | Capture timestamp verbatim from source CSV, with original `-07:00` offset. Blank for summaries. |
| `video_decode_percent` | Windows GPU Engine `engtype_VideoDecode` utilization, verbatim. `per_sample` rows only. |
| `run_avg_percent` | Run mean Video Decode %, verbatim from the summary artifact. |
| `run_max_percent` | Run peak Video Decode %, verbatim from the summary artifact. |
| `all_gpu_max_percent` | Peak across all GPU engines (not just Video Decode), where the source log reports it. |
| `samples_in_run` | Number of samples the summary was computed over. |
| `video_decode_value_count` | Raw counter value count where the source reports it (2250 in the long YouTube run). |
| `codec` | `H.264` (local file) or `VP9` (YouTube `vp09`). |
| `source_file` | Path to the raw artifact inside this repository. |
| `notes` | Test conditions and caveats. **Quote this alongside any number.** |

## Runs in this file

| `run_id` | Case | Codec / resolution | Rows | Headline |
|---|---|---|---|---|
| `edge_local_h264_20260711` | Local loopback file in Edge | H.264 3840×2160@60, ~108.64 Mbit/s | 35 samples + 1 summary | avg 38.58% / max 42.91% Video Decode; browser view 4886 frames, 11 dropped (~0.23%), 59.8 fps recent |
| `youtube_vp9_2160p60_30s_20260712` | YouTube 2160p60, steady 30 s phase | VP9 3840×2160@60 | 1 summary | avg 25.61% / max 27.64%; 0 new dropped frames over 2048 frames |
| `youtube_vp9_2160p60_long_20260712` | YouTube 2160p60, longer window incl. startup | VP9 3840×2160@60 | 1 summary | avg 1.01% / max 31.28% over 90 samples (2250 raw values) |

## Evidence boundary (A / B / C)

- **A (here):** GPU counter and frame counts captured on the tested EQi12 in Edge.
- **B (not here):** ffmpeg/QSV pipeline throughput, e.g. `dataset/EQi12_qsv_concurrent_samples.csv`.
  That is a different workload; do not mix playback decode % with transcode decode %.
- **C (not here):** performance of any other mini PC, browser, GPU or driver. No value is stated.

## Known traps in the raw artifacts

Cite this file rather than reading the logs directly:

1. **Two YouTube runs, two averages.** The 90-sample "long" run includes startup and
   quality-switch phases and reports avg **1.01%**; the 30 s steady-phase run reports **25.61%**.
   These are different windows, not a contradiction and not a regression. Do not average them.
2. **250 dropped frames are in the screenshots.** YouTube's stats-for-nerds counter showed
   250 dropped frames *before* the measured 30 s phase (cumulative from playback start and
   quality switching). The steady phase added **0** new dropped frames over 2048 frames. The
   250 are retained in the raw screenshots; they are excluded from the "0 dropped" steady-play
   result, and that exclusion is stated here rather than hidden.
3. **Local vs YouTube are different codecs.** Local file is H.264; YouTube served VP9 (`vp09`).
   Decode % is not directly comparable across the two codecs or across the two capture windows.
4. **Video Decode % ≠ whole-GPU %.** The counter is `engtype_VideoDecode` utilization. Where the
   all-GPU-engine peak is reported it happens to be similar, but the two are distinct counters.
5. **Timestamps are capture-local** (`-07:00`, America/Los_Angeles lab session, 2026-07-11/12),
   not UTC and not mid-2026 deployment dates.
6. **Do not infer power draw.** These are decode-utilization percentages, not watts. Wall power
   for playback is a separate measurement; none is stated here.

## Reproducing / extending

- Raw artifacts: `codec/EQi12_Edge_4K60_GPUDecode_Samples.csv`,
  `codec/EQi12_Edge_4K60_GPUDecode_Summary.txt`,
  `codec/EQi12_YouTube_2160p60_GPUDecode_30s_Accurate.log`,
  `codec/EQi12_YouTube_2160p60_GPUDecode.log` (all under the repository root).
- The generator `dataset/_gen_browser_4k60_20261120.js` copies raw values verbatim and verifies
  13 columns on every row; it does **not** recompute statistics.
- Append-only: add new `run_id` partitions for new captures; never silently edit existing values.

## Version history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-11-20 | Initial release: 35 Edge per-sample readings + 3 run summaries (2 YouTube, 1 Edge). |
