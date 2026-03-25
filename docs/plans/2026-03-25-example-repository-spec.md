# Lazarus Build Station Example Repository Spec

> **For Codex:** build this repository as a small publishable example project that demonstrates real usage of `lazarus-build-station`.

## Goal

Create a standalone public example repository named `lazarus-build-station-example` that shows how to build a Lazarus GUI application with `lazarus-build-station`.

This repository is not a generic template generator. It is a working example and reference project that other users can inspect, clone, fork, and adapt.

## Core idea

The repository should contain:

- a small Lazarus visual application
- a real `.lpi` project that builds inside Docker using `ghcr.io/attid/lazarus-build-station:latest`
- at least one non-trivial external Lazarus visual component or package, so the example proves more than plain stock Lazarus
- clear instructions showing how to build the project with the published builder image

## Important constraints

- The app must be visual, not console-only.
- Keep it small and understandable.
- Do not invent a large product or fake business app.
- Do not add unnecessary infrastructure.
- No CI unless it is truly needed.
- No release automation needed for this example repo.
- The repository should feel clean and publishable.

## Recommended demo shape

Build a simple GUI demo application with one main form.

Recommended direction:

- a small “component showcase” style app
- one custom-looking widget or non-standard visual control
- one or two tiny interactions, for example:
  - enter text and render it into a custom control
  - switch theme/color/appearance
  - show a live preview area

The point is to prove:

- Lazarus GUI app builds in the container
- external component/package is installed correctly
- project files and build steps are understandable for other users

## Component requirement

Use a non-standard visual Lazarus component/package, not only stock LCL controls.

Examples of acceptable directions:

- a visual component library available from a public source repository
- a custom-drawn control package
- a Lazarus package that must be registered in the IDE/build process

Avoid anything overly fragile, abandoned, or requiring huge dependency chains.

Choose something that is realistic to install during repository setup and can be built reproducibly.

## Repository contents

The repository should end up with a simple structure, roughly like:

```text
.
├── README.md
├── .gitignore
├── app/
│   ├── project.lpi
│   ├── project.lpr
│   ├── main-form.pas
│   ├── main-form.lfm
│   └── ...
├── vendor/ or components/
│   └── <external component sources if vendoring is the cleanest option>
└── docs/
    └── plans/
        └── 2026-03-25-example-repository-spec.md
```

Use actual filenames that fit Lazarus conventions if a better naming scheme makes sense.

## Build and usage requirements

The README must explain:

- what the repository is
- which external component is used
- how the component is included in the project
- how to build the project with:
  - `docker pull ghcr.io/attid/lazarus-build-station:latest`
  - `docker run ... lazbuild ...`
- how to rebuild after editing locally
- any limitations or prerequisites

The main documented path must use the published image from GHCR, not local Dockerfile builds.

## Independence from local machine

Do not assume the user has Lazarus installed locally.

The primary documented workflow should be:

1. clone repo
2. pull `ghcr.io/attid/lazarus-build-station:latest`
3. mount the repo into `/workspace`
4. run `lazbuild` inside the container

If additional package registration is needed, document and automate it as much as reasonably possible.

## Git and packaging expectations

Set up the example repo as a normal standalone git repository.

Add:

- `README.md`
- `.gitignore`
- MIT `LICENSE`

Do not add:

- badges
- heavy boilerplate
- complex automation

## Verification requirements

Before claiming completion, verify:

- repository structure looks clean
- Lazarus project files exist and are coherent
- the project builds with `ghcr.io/attid/lazarus-build-station:latest` or a more specific arch tag if required
- if the chosen component requires extra setup, that setup is captured in the repository and README

If something cannot be fully verified, state exactly why.

## Deliverable expectation

At the end, report:

- final repo structure
- chosen external component and why
- exact Docker build command used for verification
- any limitations or follow-up work

## Recommended execution approach

1. Inspect which visual Lazarus component/package is easiest to demonstrate and still meaningful.
2. Create the smallest believable GUI app around it.
3. Make the project build inside `lazarus-build-station`.
4. Write a concise README for external GitHub users.
5. Verify with real containerized build commands.
