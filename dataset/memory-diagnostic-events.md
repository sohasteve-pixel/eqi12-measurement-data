# EQi12 Windows Memory Diagnostic result events

**Dataset:** [`EQi12_memory_diagnostic_events.csv`](EQi12_memory_diagnostic_events.csv)
**Device:** Beelink EQi12, Core i3-1215U, 16 GB DDR4-3200 (2×8 GB), WD SN540 512 GB NVMe.
**Test date:** 2026-07-13 (local, GMT+8). **Published:** 2026-11-25.
**License:** CC BY 4.0. Append-only.

## What this is

One unattended Windows Memory Diagnostic run on the tested EQi12, scheduled with
`bcdedit /bootsequence {memdiag}` and read back from the System event log after the
post-diagnostic boot. The CSV is a **long-format, one-row-per-field** transcription of:

- the **event 1101** XML payload (`EQi12_MemoryDiagnostic_04_RESULT_EVENTS_XML.txt`) —
  the authoritative verdict and coverage counters;
- the **event 1201** short summary and the human-readable `Message` values from
  `EQi12_MemoryDiagnostic_03_RESULT_EVENTS.csv`;
- the four Docker containers observed healthy after the reboot, from
  `EQi12_MemoryDiagnostic_05_FINAL_SUMMARY.txt`.

Values are copied verbatim from those artifacts. Nothing is inferred or recomputed.
The diagnostic was **started before Windows booted**, so the only durable record is
the event log — this dataset is that record in a citable, flat form.

## Headline result

- `CompletionType = Pass`; `NumBadPages = 0` (and all 16 per-test `TnNumBadPages = 0`).
- `TestDuration = 1074 s` (17 min 54 s); `TestCount = 12`.
- `MemorySize = 16147 MiB`; `NumPagesTested = 4104471`; `NumPagesUnTested = 2363`.
- `TestType = 10` — an enum code, **not** a duration or a count.
- `LaunchType = Unknown` — the event does not record how the test was launched.
- All four observed Docker containers were `Up 3 minutes (healthy)` after the
  post-diagnostic boot at `2026-07-13 23:35:54`.

## Field dictionary

| Column | Meaning |
|---|---|
| `event_key` | Partition/label. `1101_pass` = detailed XML fields, `1101_message` and `1201_message` = human-readable text, `1201_pass` = short verdict, `postboot_container` = container state after reboot. |
| `event_id` | Windows event ID: `1101` (detailed XML result), `1201` (short summary). Blank for container-state rows. |
| `level` | Event level, `Information` for both event IDs. Blank for container rows. |
| `provider` | `Microsoft-Windows-MemoryDiagnostics-Results`. Blank for container rows. |
| `time_created_local` | Local wall-clock time from the CSV/summary artifacts (GMT+8). |
| `time_created_utc` | `SystemTime` from the event XML, verbatim with full precision. Blank for container rows. |
| `record_id` | Windows `EventRecordID` (14828 / 14829). Blank for container rows. |
| `field` | The XML element name, `Message`, or `ContainerRecovery`. |
| `value` | Verbatim value. |
| `unit` | Unit where one exists (`MiB`, `seconds`, `count`, `pages`, `enum`, `text`, `state`). |
| `source_artifact` | Original file in `memory/` that the row was transcribed from. |

## Citation

> Beelink EQi12 Windows Memory Diagnostic result events (2026-07-13): event 1101/1201
> XML and System-log capture, one standard 16 GB pass, verbatim counters.
> `sohasteve-pixel/eqi12-measurement-data`, `dataset/EQi12_memory_diagnostic_events.csv`,
> CC BY 4.0. Retrieved 2026-11-25.

## Evidence level (A/B/C)

- **A — measured:** every row here. This is a real run on the tested machine with
  a durable event-log record; the XML is the primary evidence.
- **Not claimed:** that any memory module is universally healthy, that the result
  applies to other EQi12 units, or that the diagnostic covered 100% of physical RAM.

## Known traps

1. **UTC vs local time differ by 8 hours.** The XML `SystemTime` is
   `2026-07-14T06:36:22Z`; the CSV and summary show `2026-07-13 23:36:22` local.
   Both are the same instant. Do not read them as two separate runs.
2. **"Pass" is not full coverage.** 2,363 pages were left untested (~0.0576% of
   4,126,834 tested+untested). A pass is strong evidence, not a mathematical guarantee.
3. **`MemorySize = 16147 MiB` is not 16384 MiB.** The reported usable size is lower
   than the nominal 16 GB figure; do not overwrite it with the spec-sheet value.
4. **`TestType = 10` is an enum code**, not "10 tests" or "10 minutes". The test
   count is the separate `TestCount = 12` field.
5. **`TestDuration = 1074 s` covers the diagnostic itself**, not scheduling time,
   reboot time or the time to read the event log afterward.
6. **`LaunchType = Unknown`** — the event does not say whether the run was launched
   by the GUI wizard or by `bcdedit /bootsequence`. The scheduling script is the
   evidence for the launch method, not the event.
7. **Event 1201 carries no counters**, only `CompletionType`. Use 1101 for any
   number; 1201 is the quick-confirmation/alerting event.
8. **The blue-screen photo was taken but not yet filed** into the handoff folder at
   the time of the run (`FINAL_SUMMARY.txt` evidence note). The event log, not the
   photo, is the cited evidence here.
9. **Container health is an observation, not a memory test result.** The four
   `healthy` lines show the host came back usefully after the reboot; they are not
   part of the diagnostic verdict.

## Reproducing

`memory/EQi12_Start_MemoryDiagnostic.ps1` schedules the run and
`memory/Capture_MemoryDiagnostic_Evidence.ps1` collects the events. Run them on
your own hardware and open a PR with a comparison table; leave the original
artifacts untouched. This CSV is append-only — add new rows with new `event_key`
values, and record corrections here rather than editing rows silently.
