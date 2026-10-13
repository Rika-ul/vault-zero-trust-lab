# config/vault.hcl
# Configuration serveur HashiCorp Vault — nœud "vault-1"
# Stockage Raft intégré + listener TLS + journal d'audit

storage "raft" {
  path    = "/vault/data"
  node_id = "vault-1"

  retry_join {
    leader_api_addr = "https://vault-2:8200"
  }
  retry_join {
    leader_api_addr = "https://vault-3:8200"
  }
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/vault/tls/vault-cert.pem"
  tls_key_file  = "/vault/tls/vault-key.pem"
  # tls_disable = true   # uniquement pour tests en laboratoire isolé
}

api_addr     = "https://vault-1:8200"
cluster_addr = "https://vault-1:8201"

# Interface web activée
ui = true

# Journal d'audit (voir aussi : vault audit enable file ...)
# audit {
#   file {
#     file_path = "/vault/logs/audit.log"
#   }
# }

disable_mlock = false
