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

resource "pocketid_group" "librechat_admin" {
  name          = "librechat-admin"
  friendly_name = "LibreChat admins"
}
