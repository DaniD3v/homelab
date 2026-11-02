resource "netbird_identity_provider" "pocket_id" {
  name          = "Pocket ID"
  type          = "pocketid"
  issuer        = "https://auth.danidev.vip"
  client_id     = pocketid_client.netbird.id
  client_secret = pocketid_client.netbird.client_secret
}
