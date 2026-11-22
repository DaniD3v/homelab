---
name: librechat-agent-login
description: Use when testing the deployed LibreChat at clanker.danidev.vip as a signed-in user, through its UI or API.
---

# LibreChat agent login

- Sign in as the Pocket ID user `clanker` (`pocketid_user.clanker` in `tofu/pocket-id.tf`), never as the owner's account. It is a normal user, so people search and admin screens return 403.
- From the repository root:
  ```sh
  sops -d --extract '["STATIC_API_KEY"]' pocket-id/secrets.sops.env | .agents/skills/librechat-agent-login/run.sh login
  .agents/skills/librechat-agent-login/run.sh chat CLIProxyAPI gpt-6.1-sol 'Search the web: …'
  .agents/skills/librechat-agent-login/run.sh api GET /api/user
  ```
- `login` mints a 5-minute one-time login code through the Pocket ID API and keeps the browser session in `$XDG_RUNTIME_DIR/librechat-clanker/`; `chat` also writes `chat.png` there. Log in again when calls return 401.
- Extend `librechat.py` for other flows. Use `wait_for_load_state("load")`, not `networkidle`: LibreChat keeps connections open.
- Delete chats, agents and schedules you created.
