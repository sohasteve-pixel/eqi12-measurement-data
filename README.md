# Beelink EQi12 — Open Measurement Data

Raw, reproducible measurement data from a real home server build on a **Beelink EQi12 (Intel Core i3-1215U, 16 GB RAM, 1 TB NVMe)**. Every file here is an original artifact captured during lab tests in July 2026 — power logs, codec matrices, Docker stack benchmarks, storage, network and stability evidence. No numbers were invented; the raw logs are the source of the claims on [homelabtoolkit.com](https://homelabtoolkit.com/).

**Why open data?** Because the claims that matter ("12 W idle", "two 4K60→1080p transcodes are not real-time on this box", "one USB-A port is much slower than the others") should be checkable, not just stated. Fork it, rerun the scripts, argue with the numbers.

## Device under test

| Item | Detail |
|---|---|
| Machine | Beelink EQi12, Intel Core i3-1215U (2P+4E, up to 4.4 GHz) |
| RAM | 16 GB |
| Storage | 1 TB NVMe (internal) + external USB SSD in port tests |
| OS | Windows 11 + WSL2 (Ubuntu) / Docker Desktop |
| Measured with | Wall power meter (between wall and PSU), ffprobe/ffmpeg, pgbench, redis-benchmark, winsat, KM003C USB-C meter |

## Repository layout

| Directory | What's inside | Related guide |
|---|---|---|
| `power/` | Idle / load / sleep power logs, 24 h overnight sampling, Jellyfin transcode power | [Home server power cost guide](https://homelabtoolkit.com/build/home-server-power-cost-guide/) |
| `codec/` | Intel QSV encode/decode matrices (H.264, HEVC, VP9, AV1), 4K60→1080p60 transcode logs, 2- and 4-stream concurrency | [Jellyfin Intel QSV setup](https://homelabtoolkit.com/build/jellyfin-intel-qsv-windows/) · [QSV codec matrix](https://homelabtoolkit.com/lab/intel-i3-1215u-qsv-codec-support/) |
| `docker/` | Docker Compose stack benchmarks (nginx HTTP, PostgreSQL, Redis), auto-start & AC-loss recovery cycles | [Docker auto-start guide](https://homelabtoolkit.com/build/docker-desktop-auto-start-home-server/) · [AC power recovery](https://homelabtoolkit.com/build/mini-pc-ac-power-recovery/) |
| `storage/` | Internal NVMe & USB port throughput, SSD idle power, S.M.A.R.T. snapshots | [Storage guide](https://homelabtoolkit.com/build/beelink-eqi12-windows-home-server/) |
| `network/` | Dual 1GbE NIC tests, Wi-Fi 6 two-round bidirectional throughput, WOL from S3/S5 | [Networking results](https://homelabtoolkit.com/hardware/beelink-eqi12/) |
| `stability/` | 12 h 57 m long-run stability, 24 h event summary | [Stability report](https://homelabtoolkit.com/lab/beelink-eqi12-docker-benchmark/) |
| `memory/` | Windows Memory Diagnostic scheduled-run results | — |
| `wsl/` | WSL2 Ubuntu baseline under the Docker stack | — |
| `misc/` | Audio/BT tests, YouTube 2160p60 GPU decode, reboot cycle logs | [Full EQi12 review hub](https://homelabtoolkit.com/hardware/beelink-eqi12/) |

## Quick facts (with the raw logs to back them up)

- **~12 W idle at the wall** with nginx + PostgreSQL 17 + Redis 8 + Jellyfin all running (`power/`).
- **Two simultaneous 4K60→1080p60 QSV transcodes** run, but **four do not stay real-time** on this i3-1215U (`codec/QSV_*streams*`).
- **5/5 normal restarts, 5/5 shutdown-WOL, 3/3 AC-loss recovery** — the stack comes back on its own (`docker/`, `network/`).
- **One front USB-A path is dramatically slower** than the other ports for a 50 GiB copy (`storage/`).
- **Dual 1GbE** — both NICs are gigabit, no 2.5G on this model (`network/`).

## Reproduce / contribute

- Test scripts (`*.ps1`) are kept alongside their logs — run them on your own mini PC and open a PR with a comparison table.
- File naming keeps the original Chinese lab names (e.g. `EQi12_Power_EQi12_功耗测试记录_2026-07-13.txt`) so artifacts are traceable to the original test session.
- Corrections welcome: if a number here disagrees with your own measurement, open an issue with your setup details.

## License

Data and logs: [CC BY 4.0](LICENSE) — use freely with attribution (link to this repo or homelabtoolkit.com). Test scripts: MIT.
