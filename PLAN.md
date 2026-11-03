# Plan

## Decisions

- doco-cd runs self-managed on the main host (Debian 13 under Incus, distro Docker 26) and polls `https://github.com/DaniD3v/homelab.git`. Forgejo is skipped for now.
- The laptop (rootless Podman) has no target; stacks are tested there manually with plain compose.
- Minimal config: copy only needed upstream parts, no restated defaults, `.yaml` extensions.
- Images are pinned by tag and digest; data lives in named volumes.
- Pocket ID objects that only exist in its database (the NetBird OIDC client) are managed by OpenTofu in `tofu/`, run from the laptop; state is gitignored and lives only there.
- NetBird runs split (management, signal, relay) with Pocket ID as its external issuer, so no NetBird owner, PAT or Dex exists. Its IdP manager is `none`: Pocket ID API keys cannot be scoped, and NetBird does not need to read or manage Pocket ID users. The combined server cannot trust an external issuer; the split layout is upstream's secondary "advanced guide" path, accepted knowingly.
- Accounts stay manual: the Pocket ID admin via `/setup` before `auth` is forwarded publicly; the first Pocket ID user to sign in to NetBird becomes its owner, and later users are approved and promoted in the dashboard.

## Later

- Staging: a host or branch that deploys before main, promoted by merge.
- Upstream fix: netbirdio/dashboard defaults `AUTH_REDIRECT_URI`/`AUTH_SILENT_REDIRECT_URI` to `/#callback`/`/#silent-callback` (`src/utils/config.ts`); OAuth2 forbids fragments, so every deployment overrides them with `/nb-auth`/`/nb-silent-auth`.
- Upstream fix: the netbirdio/dashboard image answers its own OAuth callback routes `/nb-auth`/`/nb-silent-auth` with HTTP 404 (nginx `try_files … =404` serves `404.html`); they should serve them with 200.
- Make every random secret easy to regenerate (e.g. one Just recipe that re-creates a secret file blindly). Data-encryption keys (Pocket ID `ENCRYPTION_KEY`, NetBird `store.encryptionKey`) are excluded: changing one makes existing data undecryptable (Pocket ID fails to start).
- Upstream feature: NetBird cannot map IdP/JWT groups to account roles (admin/user); only network groups sync. Propose a group→role mapping (e.g. `netbird-admin` → admin).
- Upstream fix: NetBird management defaults an unset `Relay.CredentialsTTL` for token generation but `refreshRelayTokens` (`management/internals/shared/grpc/token_mgr.go`) still calls `time.NewTicker(0)`, which panics; the refresh loop should use the defaulted duration.
- Upstream fix: Caddy 2.11.6+ defaults `read_body_idle` to 1 minute, which cuts long-lived gRPC streams that legitimately send nothing (NetBird's Job and signal streams fail with 502/`RST_STREAM` every 60 s). Route-level `timeouts` cannot override it in v2.11.7; caddyserver/caddy#8121 (merged 2026-10-03, unreleased) fixes that. No issue covers gRPC yet; propose exempting streaming gRPC from the default or documenting the per-route override.
- Upstream fix: `netbirdio/netbird` Tofu provider 0.0.11 `netbird_account_settings` resets settings it does not model (applying only `user_approval_required = false` nulled `ipv6_enabled_groups`); it should send unmanaged settings unchanged.
