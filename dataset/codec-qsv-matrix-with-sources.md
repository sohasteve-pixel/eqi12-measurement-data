# EQi12 Intel QSV codec matrix, with source provenance

**Dataset:** `dataset/EQi12_codec_qsv_matrix_with_sources.csv` · 12 rows · 19 columns
**Hardware:** Beelink EQi12, Intel Core i3-1215U (6C/8T), 16 GB DDR4-3200, WD PC SN540 512 GB NVMe
**License:** CC BY 4.0 (see root `LICENSE`)
**Published:** 2026-11-23

## What this is

A citable table of the QSV codec tests run on our EQi12, joined to the ffprobe metadata of the exact source clips used. Each row preserves the original verbatim value from its source log; the `record_type` column separates generated sources (`SOURCE`) from codec tests (`TEST`), and `included_in_results` marks the one excluded invalid run.

The point of joining sources to results: a bare "23.3x VP9 decode" is not reproducible unless you know the clip was 1920x1080, `yuv420p`, 60/1 fps, 5.000000 s and 2,931,944 bytes. All of that is here, from the project's own ffprobe dump.

## Source logs

| File | Role |
|---|---|
| `codec/EQi12_Codec_00_SOURCE_GENERATION.csv` | Three generated clips: name, generation exit code, seconds, bytes |
| `codec/EQi12_Codec_00_SOURCES_FFPROBE.txt` | ffprobe JSON per clip: codec_name, profile, width, height, pix_fmt, r_frame_rate, duration, size |
| `codec/EQi12_Codec_01_CODEC_MATRIX.csv` | Valid corrected run: 7 tests with Passed / ExitCode / Frames / Speed / WallSeconds / LastError |
| `codec/EQi12_Codec_02_FINAL_RESULT.txt` | Final summary plus the retained `INVALID_FIRST` all-fail run |
| `codec/EQi12_Codec_03_COMPACT_SUMMARY.txt` | Human-readable summary of the valid run |

## Column dictionary

| Column | Meaning |
|---|---|
| `record_type` | `SOURCE` = clip generation row; `TEST` = codec test row |
| `test_id` | Identifier as written in the source log (`DEC_H264_QSV_4K60`, `ENC_AV1_QSV_PROBE`, …) |
| `source_codec` … `source_bytes` | ffprobe fields of the clip used, verbatim. Blank where the test used an external/source clip not generated here (H.264 4K60 decode and the H.264→H.264 transcode). |
| `operation` | `gen`, `decode`, `encode`, `transcode`, or `unknown` for the invalid run |
| `passed_verbatim`, `exit_code_verbatim`, `frames_verbatim`, `speed_verbatim`, `wall_seconds_verbatim`, `last_error_verbatim` | Exact strings from the source CSV. Not normalised: `True`/`False`, `N/A`, `Conversion failed!` are kept as written. |
| `source_log` | File the row was copied from |
| `included_in_results` | `yes` for all valid rows including the unsupported AV1 encode; `no` only for `INVALID_FIRST_ALL_FAIL` |
| `note` | Caveats and cross-references |

## Evidence levels (A / B / C)

- **A — measured here:** all `TEST` rows were executed on this EQi12; the `SOURCE` rows were generated here and ffprobed here.
- **B — component-level:** these are codec-engine results on an i3-1215U. They do **not** establish performance of any application (Jellyfin, Plex, browsers). Do not write "Jellyfin does 23.3x VP9" from this table.
- **C — not tested here:** application-level playback, container overhead, and any device other than the EQi12. No numbers are supplied for these.

## Known traps

1. **AV1 decode passes, AV1 encode fails.** `DEC_AV1_QSV_1080P60` = True @ 16.7x; `ENC_AV1_QSV_PROBE` = False, exit `-40`, `Conversion failed!`. The hardware log for the encode says "Current codec type is unsupported / Function not implemented". Both rows are `included_in_results = yes` — a failure is a result.
2. **The `INVALID_FIRST_ALL_FAIL` row is not a hardware result.** An earlier 0.03-second all-fail run came from a script argument error. It is retained for provenance with `included_in_results = no`. Exclude it from any pass-rate calculation: 6 of 7 valid tests passed, and the 7th (AV1 encode) is a genuine unsupported result.
3. **Source bytes match ffprobe.** HEVC 1,982,230, VP9 2,931,944, AV1 3,484,527 bytes appear identically in generation CSV and ffprobe `format.size`. If they ever diverge, do not average them — investigate.
4. **Speed is per-test, not per-codec-winner.** The 300-frame decode tests ran at different resolutions (H.264 at 4K60; HEVC/VP9/AV1 at 1080p60). Comparing 4.17x against 18.9x across different resolutions is not a fair ranking.
5. **Two H.264 tests have no generated source row.** `DEC_H264_QSV_4K60` and `TRANSCODE_H264_TO_H264_QSV` source fields are blank because their input was not one of the three generated 1080p60 clips. Blank means "not generated here", not "missing data".
6. **`0.03x` in the invalid row is a script artefact.** Do not read it as a speed measurement.
7. **Exit code `-40` is FFmpeg's "Function not implemented"**, as stated in the codec log — not a timeout, not a missing file.

## Cite

> Beelink EQi12 Intel QSV codec matrix with source provenance (2026-11-23), `sohasteve-pixel/eqi12-measurement-data`, CC BY 4.0.
