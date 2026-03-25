# Lazarus Build Station Example

This repository is a small, publishable example that demonstrates how to build a
Lazarus GUI application with the published
[`ghcr.io/attid/lazarus-build-station`](https://ghcr.io/attid/lazarus-build-station)
image family.

The app is intentionally tiny: one main form, a live text preview, and a simple
theme switcher. The non-stock visual dependency is
[`BGRA Controls`](https://github.com/bgrabitmap/bgracontrols), backed by
[`BGRABitmap`](https://github.com/bgrabitmap/bgrabitmap). Both packages are
vendored into `components/` so the example can be inspected and adapted without
an extra package manager step.

## Repository layout

```text
.
├── README.md
├── LICENSE
├── app/
│   ├── demologic.pas
│   ├── lazarus_build_station_example.lpi
│   ├── lazarus_build_station_example.lpr
│   ├── mainform.lfm
│   └── mainform.pas
├── components/
│   ├── bgracontrols/
│   └── bgrabitmap/
└── scripts/
    └── build-in-container.sh
```

## External component

- Package: `components/bgracontrols/bgracontrols.lpk`
- Upstream repository: `bgrabitmap/bgracontrols`
- Vendored commit: `a60e16f`
- Required base package: `components/bgrabitmap/bgrabitmap/bgrabitmappack.lpk`
- Base package commit: `44a6526`

The demo uses `TBCButton` and `TBGRAShape` from BGRA Controls. That keeps the
application understandable while still proving that a real external Lazarus
package is available during the build.

## Build with the published image

Pull the published builder image:

```bash
just pull
```

Build and verify all 4 target combinations from a clean checkout:

```bash
just make
```

This runs 4 independent builds:

- `linux/x86_64`
- `win64/x86_64`
- `linux/i386`
- `win32/i386`

The helper uses two architecture-specific published tags under the hood:
`ghcr.io/attid/lazarus-build-station:latest-amd64` for `linux/x86_64` and
`win64/x86_64`, and `ghcr.io/attid/lazarus-build-station:latest-i386` for
`linux/i386` and `win32/i386`.

Each build registers `BGRABitmapPack` and `bgracontrols` inside an isolated
Lazarus config directory and then runs `lazbuild` on
`app/lazarus_build_station_example.lpi`. Built binaries are copied into:

```text
dist/linux-x86_64/
dist/win64-x86_64/
dist/linux-i386/
dist/win32-i386/
```

If you want individual targets instead of the full matrix:

```bash
just make-linux64
just make-win64
just make-linux32
just make-win32
```

## Rebuild after editing locally

Edit the files under `app/`, then rerun `just make`.
The build writes Lazarus unit output into `app/lib/` and final binaries into
`dist/`.

Useful local helpers:

```bash
just test
just clean
just status
```

`just make` expands to four Docker-backed runs over two published image tags.
The per-target form looks like this:

```bash
docker run --rm \
  -v "$(pwd):/workspace" \
  --user "$(id -u):$(id -g)" \
  -e TARGET_OS=linux \
  -e TARGET_CPU=x86_64 \
  ghcr.io/attid/lazarus-build-station:latest-amd64 \
  bash /workspace/scripts/build-in-container.sh
```

If you want the raw `lazbuild` steps instead of the helper script, this is the
equivalent flow inside the container:

```bash
mkdir -p /tmp/lazarus-build-station-example
lazbuild --pcp=/tmp/lazarus-build-station-example -B /workspace/components/bgrabitmap/bgrabitmap/bgrabitmappack.lpk
lazbuild --pcp=/tmp/lazarus-build-station-example --add-package-link /workspace/components/bgrabitmap/bgrabitmap/bgrabitmappack.lpk
lazbuild --pcp=/tmp/lazarus-build-station-example -B /workspace/components/bgracontrols/bgracontrols.lpk
lazbuild --pcp=/tmp/lazarus-build-station-example --add-package-link /workspace/components/bgracontrols/bgracontrols.lpk
lazbuild --pcp=/tmp/lazarus-build-station-example -B /workspace/app/lazarus_build_station_example.lpi
```

## Limitations

- The primary workflow assumes Docker is available locally.
- The example demonstrates Linux container builds; cross-target packaging is out
  of scope for this repository.

## Releases

The repository includes a GitHub Actions workflow at
`.github/workflows/release.yml`.

On a pushed tag matching `v*`, it:

- builds `linux/x86_64`
- builds `win64/x86_64`
- builds `linux/i386`
- builds `win32/i386`
- archives each binary as a `.tar.gz`
- uploads the archives to the corresponding GitHub Release

That makes `v1.0.0` a good first validation tag for the release pipeline.
