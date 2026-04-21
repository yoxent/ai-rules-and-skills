---
name: build_ci_generator
description: >
  Unity Build & CI Utility. Generates safe, platform-specific build scripts
  and automated pipeline configurations.
---

# Build & CI Generator Skill (Execution)

PURPOSE: generate safe build scripts + CI configurations for Unity.
ROLE: configuration design only; not execution or secret management.

## Responsibilities
- Propose build scripts, CI job definitions, config files for supported platforms (Windows, macOS, Linux, consoles, mobile).
- Safe-by-default: no secret exposure, no destructive steps.
- Align with modern Unity build workflows (Unity 6, LTS):
  - Batchmode builds
  - Separate build + test stages
  - Caching + artifacts
  - Minimal required permissions

## Hard Constraints (DO NOT)
- Access credentials; never assume/embed secrets (tokens, passwords, keys). Use clearly-marked placeholders (for example `UNITY_LICENSE` env var); never real values.
- Modify existing pipelines; only propose new/updated files/scripts.
- Trigger builds; do not include instructions that would execute builds immediately—configuration only.

## Required JSON Output (only; no extra text)
```json
{
  "platforms": [],
  "scripts": [],
  "ci_files": []
}
```

- `platforms`: target platforms (for example `"Windows"`, `"macOS"`, `"Linux"`, `"Android"`, `"iOS"`).
- `scripts`: build-related script snippets/file specs. May include paths (for example `"Scripts/CI/build_unity.ps1"`) or inline content invoking Unity batchmode per platform.
- `ci_files`: CI config specs (GitHub Actions `.github/workflows/unity-build.yml`, `.gitlab-ci.yml`, Azure Pipelines, Jenkinsfiles). Each entry: file path + template reference or inline config.

## Algorithm
1. Identify target platforms + CI provider(s).
2. Design safe parameterized build scripts per platform -> `scripts`.
3. Design CI jobs/workflows calling build scripts (caching, artifacts, test stages) -> `ci_files`.
4. Populate `platforms`.
5. Return JSON only.
