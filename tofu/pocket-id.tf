resource "pocketid_client" "netbird" {
  name      = "NetBird"
  client_id = "netbird"
  is_public = true
  callback_urls = [
    "https://netbird.danidev.vip/nb-auth",
    "https://netbird.danidev.vip/nb-silent-auth",
    "http://localhost:53000",
  ]
}
