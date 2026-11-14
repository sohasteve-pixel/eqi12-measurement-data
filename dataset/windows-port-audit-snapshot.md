# EQi12 Windows Port & Firewall Audit Snapshot — citable dataset

Row-per-record copy of the two raw CSV exports behind the Windows home-server port audit
taken on the Beelink EQi12 on 2026-07-13: every TCP listening socket and every enabled
inbound *allow* firewall rule, verbatim. Nothing is averaged, deduplicated, curated or
reconstructed. The two source exports are combined into one file with a `record_type`
partition key so a third party can re-group the audit without reading the mixed-format logs.

- **File:** `dataset/EQi12_windows_port_audit_snapshot.csv` (UTF-8, comma-separated, all fields quoted)
- **Version:** 1.0 — 2026-11-15
- **Rows:** 206 records, 11 columns (37 `TCP_LISTENER` + 169 `INBOUND_ALLOW_RULE`)
- **Source exports:** `security/EQi12_Security_02_TCP_LISTENERS.csv`, `security/EQi12_Security_06_ENABLED_INBOUND_ALLOW.csv`
- **License:** [CC BY 4.0](../LICENSE) — use, chart, reanalyse, with attribution
- **Canonical URL:** https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_windows_port_audit_snapshot.csv

## Why this file exists

A listener dump tells you what is listening; the firewall rule export tells you what is
*invited in*. Most home-server advice discusses ports as bare numbers ("close 445"). This
snapshot keeps the **binding address** next to each port, which is what actually decides
exposure: on this machine port 445 is bound only to `::`, while 139 is bound to four
specific addresses including three Docker bridge interfaces. Port numbers alone cannot
reproduce that conclusion.

The file also deliberately retains two untidy facts rather than cleaning them: the raw
listener export has **37 rows** while the published article summarises **36 bindings**, and
**20 of the 169 rule names are duplicates**. Both are documented below. A dataset that
silently harmonised those would be easier to quote and harder to audit.

## How to cite

> Steve (HomeLab Toolkit), *Beelink EQi12 Windows Port & Firewall Audit Snapshot*, v1.0, 2026.
> Dataset: `eqi12-measurement-data/dataset/EQi12_windows_port_audit_snapshot.csv`.
> CC BY 4.0. https://github.com/sohasteve-pixel/eqi12-measurement-data

```bibtex
@misc{eqi12_port_audit_2026,
  author       = {{HomeLab Toolkit}},
  title        = {Beelink EQi12 Windows Port and Firewall Audit Snapshot (v1.0)},
  year         = {2026},
  howpublished = {\url{https://github.com/sohasteve-pixel/eqi12-measurement-data/blob/main/dataset/EQi12_windows_port_audit_snapshot.csv}},
  note         = {CC BY 4.0. 37 verbatim TCP listener bindings and 169 enabled inbound allow rules, single-machine snapshot of 2026-07-13.}
}
```

## Field dictionary

| Column | Meaning |
|---|---|
| `record_type` | Partition key: `TCP_LISTENER` or `INBOUND_ALLOW_RULE`. **Do not compare or join across these groups** — they are different objects from different exports. |
| `source_file` | Name of the verbatim raw export this row came from. |
| `source_row` | 1-based data-row number inside that raw export (header excluded), so every row can be traced back line by line. |
| `address` | `TCP_LISTENER` only. Verbatim local bind address (`::`, `0.0.0.0`, `127.0.0.1`, `::1`, a LAN IP or a Docker bridge IP). |
| `port` | `TCP_LISTENER` only. Verbatim local TCP port as a string, not a number — do not sort numerically without casting. |
| `pid` | `TCP_LISTENER` only. Verbatim owning process ID (PID 4 = Windows `System`). |
| `process` | `TCP_LISTENER` only. Verbatim process name resolved from the PID. |
| `display_name` | `INBOUND_ALLOW_RULE` only. Verbatim Windows firewall rule display name. **Not a unique key** — see trap 2. |
| `profile` | `INBOUND_ALLOW_RULE` only. Verbatim profile string; may contain commas (`Domain, Private`), so parse with a CSV reader, not `split(",")`. |
| `direction` | `INBOUND_ALLOW_RULE` only. Always `Inbound` — this export was already filtered. |
| `action` | `INBOUND_ALLOW_RULE` only. Always `Allow` — this export was already filtered. |

Empty cells mean the column does not apply to that `record_type` — **not** a missing
measurement. All 11 columns are present on every row.

## Evidence boundary (A / B / C)

| Class | Meaning | May appear here? |
|---|---|---|
| **A** | Directly measured on the tested Beelink EQi12, with raw data | Yes — every value is verbatim from the two PowerShell CSV exports |
| **B** | A component benchmark used for capacity reasoning, not an end-to-end result | No |
| **C** | Not measured | No — no value at all is stated for unmeasured things |

Scope limits for reuse:

- All values describe **one configuration on one day**: Beelink EQi12 (Intel Core i3-1215U,
  16 GB DDR4-3200, WD PC SN540 512 GB NVMe, 2x Realtek GbE, Intel AX200), Windows 11 with
  Docker Desktop, a Jellyfin container and a third-party VPN client installed. They are not
  claims about other mini PCs, Windows builds or container runtimes.
- This is a **single snapshot**, not a time series. It says nothing about how the listening
  set changed across reboots, updates or service restarts.
- The 169 rows are **enabled inbound allow rules only**. They are not the total firewall rule
  count, and they are not a list of ports that are actually reachable — a rule can exist with
  no listener, and a listener can exist with no allow rule.
- No reachability test, port scan from a second host, WAN-side probe or IPv6 routing test was
  performed as part of this export. "Bound to `0.0.0.0`" describes a bind scope, not a
  verified external exposure.
- Rule names such as `HNS Container Networking - ...` carry GUIDs that are specific to this
  machine's Docker/WSL network state; they will not reproduce on another host.

## Known traps in the raw artifacts

1. **37 rows vs the article's "36 bindings".** `EQi12_Security_02_TCP_LISTENERS.csv` contains
   37 data rows and 37 distinct `(address, port)` pairs, spread over 25 distinct ports. The
   published article's summary table states 36 bindings. We did **not** silently align the
   dataset to the article or edit the article to match: the raw export is authoritative here,
   and the one-row discrepancy is left visible for anyone re-deriving the count. Quote 25
   *unique ports* and 37 *raw rows*, and check which convention you need.
2. **Rule names are not unique.** 20 of the 169 `display_name` values occur more than once
   (for example `Network Discovery (WSD-In)`, `DIAL protocol server (HTTP-In)`, several
   `Cast to Device streaming server` variants). Deduplicating on the name collapses 169 rules
   to 149 and produces the wrong count. Use `source_row` as the key.
3. **`profile` contains commas.** Values like `Domain, Private` and
   `Domain, Private, Public` are inside quoted fields. Every field in this CSV is quoted for
   exactly this reason; a naive comma split shifts the columns and corrupts the row.
4. **25 ports != 25 sockets.** One port may bind several interfaces (139 binds four, 49664
   binds two). Counting distinct ports and counting listener rows answer different questions.
5. **The bind address is the finding, not the port number.** 445 appears once, bound to `::`;
   139 appears four times on specific addresses including Docker bridges `172.18.0.1`,
   `172.20.160.1`, `172.26.176.1`. Collapsing rows to "ports open" throws away the exposure
   information. Likewise `127.0.0.1` / `::1` are loopback-only, not LAN-reachable.
6. **The two TEMP rule exports are empty, not missing.** `EQi12_Security_07_TEMP_RULES_BEFORE.csv`
   and `..._08_TEMP_RULES_AFTER.csv` contain no data rows (header/BOM only). That means zero
   temporary firewall rules before and after the session — a valid measured result, not a
   failed capture. They are deliberately not represented as rows in this snapshot.
7. **`direction` and `action` are constant by construction.** The source command filtered on
   enabled + inbound + allow before exporting. Do not read these columns as evidence that the
   host has no block rules, no outbound rules or no disabled rules.
8. **Third-party software is in the data.** `lightningx-windows-amd64` contributes four
   listeners (three loopback, one bound to a Docker bridge) and Jellyfin binds `0.0.0.0:8096`
   because Docker publishes on all interfaces by default. These are properties of this
   machine's installed software, not Windows defaults.
9. **PIDs are point-in-time.** `pid` values identify processes at capture time and are reused
   after restart; never treat them as stable identifiers across snapshots.
