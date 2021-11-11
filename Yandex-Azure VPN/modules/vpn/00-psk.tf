#-------------------------------
# we generate random password to use as PSK in S2S VPN
#-------------------------------
resource "random_password" "psk-plaintext" {
    lifecycle {
    prevent_destroy = false
  }
  length           = 16
  special          = true
  override_special = "_%@"
}


#-------------------------------
# We create KMS-key to encrypt our PSK
#-------------------------------

resource "yandex_kms_symmetric_key" "vpn-key" {
    lifecycle {
    prevent_destroy = false
  }
  name              = "az-yc-vpn-key"
  description       = "encryption key for psk string"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" // equal to 1 year
}

#-------------------------------
# We encrypt out psk into ciphertext to securely push it into VM metadata on yandex
#-------------------------------


resource "yandex_kms_secret_ciphertext" "psk-encrypted" {
    lifecycle {
    prevent_destroy = false
  }
  key_id      = yandex_kms_symmetric_key.vpn-key.id
  plaintext   = random_password.psk-plaintext.result
}