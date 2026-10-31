# Plan

## Decisions

- doco-cd runs self-managed on the main host (Flatcar, Docker) and polls `https://github.com/DaniD3v/homelab.git`. Forgejo is skipped for now.
- The laptop (rootless Podman) has no target; stacks are tested there manually with plain compose.
- Minimal config: copy only needed upstream parts, no restated defaults, `.yaml` extensions.
- Images are pinned by tag and digest; data lives in named volumes.

## Later

- Staging: a host or branch that deploys before main, promoted by merge.
