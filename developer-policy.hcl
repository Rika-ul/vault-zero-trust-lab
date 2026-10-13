# policies/developer-policy.hcl
#
# Exemple de politique ACL "moindre privilège" pour une équipe applicative.
# Le rôle n'a accès qu'aux secrets de SA propre application
# (ex. chaîne de connexion DB, clé d'API) — jamais à l'ensemble du coffre-fort.

# Lecture seule des secrets de l'application cible
path "secret/data/apps/mobile-banking/*" {
  capabilities = ["read", "list"]
}

# Pas d'écriture ni de suppression sur ce chemin pour le rôle "développeur"
path "secret/metadata/apps/mobile-banking/*" {
  capabilities = ["list"]
}

# Interdiction explicite d'accès aux secrets des autres applications
path "secret/data/apps/*" {
  capabilities = ["deny"]
}

# Interdiction d'administration (sys/, auth/, policies)
path "sys/*" {
  capabilities = ["deny"]
}

# ---------------------------------------------------------------
# Application de la politique à un rôle AppRole (exemple) :
#
#   vault policy write developer-mobile-banking developer-policy.hcl
#
#   vault write auth/approle/role/mobile-banking-app \
#       token_policies="developer-mobile-banking" \
#       token_ttl=1h \
#       token_max_ttl=4h
# ---------------------------------------------------------------
