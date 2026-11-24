resource "pocketid_client" "netbird" {
  name      = "NetBird"
  client_id = "netbird"
  is_public = true
  callback_urls = [
    "https://vpn.danidev.vip/nb-auth",
    "https://vpn.danidev.vip/nb-silent-auth",
    "http://localhost:53000",
  ]
}

resource "pocketid_client" "librechat" {
  name          = "LibreChat"
  client_id     = "librechat"
  is_public     = true
  callback_urls = ["https://clanker.danidev.vip/oauth/openid/callback"]
}

# Obot's OIDC auth provider sends users back to the root, which forwards to /oauth2/callback.
resource "pocketid_client" "obot" {
  name          = "Obot"
  client_id     = "obot"
  is_public     = false
  callback_urls = ["https://mcp.danidev.vip/"]
}

output "obot_client_secret" {
  value     = pocketid_client.obot.client_secret
  sensitive = true
}

resource "pocketid_group" "librechat_admin" {
  name          = "librechat-admin"
  friendly_name = "LibreChat admins"
}

# Agents sign in as this user to test LibreChat. See .agents/skills/librechat-agent-login.
resource "pocketid_user" "clanker" {
  username     = "clanker"
  email        = "clanker@example.com"
  first_name   = "Clanker"
  last_name    = ""
  display_name = "Clanker"
}
