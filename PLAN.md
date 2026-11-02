# Plan

## Decisions

- doco-cd runs self-managed on the main host (Debian 13 under Incus, distro Docker 26) and polls `https://github.com/DaniD3v/homelab.git`. Forgejo is skipped for now.
- The laptop (rootless Podman) has no target; stacks are tested there manually with plain compose.
- Minimal config: copy only needed upstream parts, no restated defaults, `.yaml` extensions.
- Images are pinned by tag and digest; data lives in named volumes.
- Pocket ID and NetBird objects that only exist in their databases (OIDC client, identity provider) are managed by OpenTofu in `tofu/`, run from the laptop; state is gitignored and lives only there.
- Accounts stay manual: the Pocket ID admin via `/setup` before `auth` is forwarded publicly; the NetBird Pocket ID user is approved and promoted by the owner in the dashboard.

## Later

- Staging: a host or branch that deploys before main, promoted by merge.
- Upstream fix: netbirdio/dashboard defaults `AUTH_REDIRECT_URI`/`AUTH_SILENT_REDIRECT_URI` to `/#callback`/`/#silent-callback` (`src/utils/config.ts`); OAuth2 forbids fragments, so every deployment overrides them with `/nb-auth`/`/nb-silent-auth`.
- Upstream fix: the netbirdio/dashboard image answers its own OAuth callback routes `/nb-auth`/`/nb-silent-auth` with HTTP 404 (nginx `try_files … =404` serves `404.html`); they should serve them with 200.
- Make every random secret easy to regenerate (e.g. one Just recipe that re-creates a secret file blindly). Data-encryption keys (Pocket ID `ENCRYPTION_KEY`, NetBird `store.encryptionKey`) are excluded: changing one makes existing data undecryptable (Pocket ID fails to start).
- Upstream feature: NetBird cannot map IdP/JWT groups to account roles (admin/user); only network groups sync. Propose a group→role mapping (e.g. `netbird-admin` → admin).
- Upstream fix: `netbirdio/netbird` Tofu provider 0.0.11 `netbird_account_settings` resets settings it does not model (applying only `user_approval_required = false` nulled `ipv6_enabled_groups`); it should send unmanaged settings unchanged.
