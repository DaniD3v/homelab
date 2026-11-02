resource "pocketid_client" "netbird" {
  name          = "NetBird"
  callback_urls = ["https://netbird.danidev.vip/oauth2/callback"]
}
