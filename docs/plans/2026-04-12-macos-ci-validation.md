# macOS CI Validation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add an experimental GitHub Actions workflow that validates native macOS Lazarus builds for `darwin-x86_64` and `darwin-arm64` on every push.

**Architecture:** Keep the existing release workflow unchanged for Docker-backed Linux and Windows builds. Add a separate `macos-build.yml` workflow that runs on `macos-latest`, installs Lazarus/FPC via Homebrew, and calls a dedicated native build script. The native script should mirror the current package-registration/build flow closely so Darwin support is isolated and easy to debug.

**Tech Stack:** GitHub Actions, Homebrew, Lazarus, FPC, bash

---

### Task 1: Add a failing workflow test target

**Files:**
- Create: `.github/workflows/macos-build.yml`

**Step 1: Write the failing workflow**

Create `.github/workflows/macos-build.yml` with:
- triggers: `push`, `workflow_dispatch`
- one `build-macos` job on `macos-latest`
- `strategy.fail-fast: false`
- matrix entries for `darwin-x86_64` and `darwin-arm64`
- a placeholder build step that calls `bash ./scripts/build-on-macos.sh`
- packaging/upload steps expecting `dist/darwin-x86_64/lazarus_build_station_example` and `dist/darwin-arm64/lazarus_build_station_example`

**Step 2: Run a workflow syntax check to verify it fails functionally**

Run a local YAML sanity check if available, then inspect the file manually.
Expected: the workflow is syntactically valid but would fail in CI because `scripts/build-on-macos.sh` does not exist yet.

**Step 3: Commit**

```bash
git add .github/workflows/macos-build.yml
git commit -m "ci: add macos validation workflow scaffold"
```

### Task 2: Add the native macOS build script

**Files:**
- Create: `scripts/build-on-macos.sh`

**Step 1: Write the failing script contract**

Create `scripts/build-on-macos.sh` so it accepts:
- `TARGET_OS` defaulting to `darwin`
- `TARGET_CPU` defaulting to `arm64`
- `PCP_DIR`
- `PROJECT_FILE`
- `BGRABITMAP_PKG`
- `BGRACONTROLS_PKG`
- `ARTIFACTS_DIR`

The first version should print the target values and exit non-zero if `lazbuild` is missing.

**Step 2: Verify the failure mode**

Run:
```bash
cd ../lazarus-build-station-example
bash scripts/build-on-macos.sh
```
Expected: FAIL on non-macOS development hosts or hosts without `lazbuild`, proving the script checks prerequisites before building.

**Step 3: Write minimal implementation**

Expand the script to:
- create isolated `PCP_DIR` and `ARTIFACTS_DIR`
- choose `LAZBUILD_ARGS=(--os=darwin --cpu=<target> --ws=cocoa)`
- build and register `bgrabitmappack.lpk`
- build and register `bgracontrols.lpk`
- build `app/lazarus_build_station_example.lpi`
- copy the final binary into `dist/darwin-<cpu>/`

**Step 4: Run the script contract check again**

Run:
```bash
cd ../lazarus-build-station-example
bash scripts/build-on-macos.sh
```
Expected: still fails locally without macOS toolchain, but only because prerequisites are absent, not because the script is malformed.

**Step 5: Commit**

```bash
git add scripts/build-on-macos.sh
git commit -m "feat: add native macos build script"
```

### Task 3: Connect Homebrew bootstrap and artifact flow

**Files:**
- Modify: `.github/workflows/macos-build.yml`

**Step 1: Write the failing bootstrap steps**

Add steps that:
- print `sw_vers`
- run `brew update`
- install `fpc` and `lazarus`
- print `which lazbuild`, `lazbuild --version`, and `fpc -i`

**Step 2: Verify the expected failure mode conceptually**

Because GitHub-hosted macOS is not available locally, verify by static review that:
- build step comes after install step
- environment variables map to matrix outputs
- artifact path matches the script output directory

Expected: if CI fails, it should fail in install/build logs rather than YAML structure.

**Step 3: Write minimal packaging implementation**

Ensure workflow packages `matrix.output_file` into `${matrix.artifact_name}.tar.gz` and uploads it through `actions/upload-artifact@v4`.

**Step 4: Commit**

```bash
git add .github/workflows/macos-build.yml
git commit -m "ci: bootstrap macos lazarus builds"
```

### Task 4: Local verification and handoff

**Files:**
- No additional files required

**Step 1: Run shell syntax verification**

Run:
```bash
cd ../lazarus-build-station-example
bash -n scripts/build-on-macos.sh
```
Expected: no output, exit 0.

**Step 2: Review workflow file**

Run:
```bash
cd ../lazarus-build-station-example
git diff -- .github/workflows/macos-build.yml scripts/build-on-macos.sh docs/plans/2026-04-12-macos-ci-validation.md
```
Expected: only the new workflow, new script, and plan file are changed.

**Step 3: Push and inspect CI**

Push the branch and inspect both matrix entries in GitHub Actions.
Expected: at minimum both jobs start, install steps run, and logs reveal whether Homebrew Lazarus/FPC is sufficient for `darwin-x86_64` and `darwin-arm64`.

**Step 4: Capture follow-up outcomes**

Document which architecture builds, which fails, and the exact failing command for the next iteration toward `.app` bundling.
