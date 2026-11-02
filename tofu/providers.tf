terraform {
  required_providers {
    pocketid = {
      source  = "Trozz/pocketid"
      version = "2.5.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.4.1"
    }
  }
}

data "sops_file" "pocket_id" {
  source_file = "../pocket-id/secrets.sops.env"
  input_type  = "dotenv"
}

provider "pocketid" {
  base_url  = "https://auth.danidev.vip"
  api_token = data.sops_file.pocket_id.data["STATIC_API_KEY"]
}
