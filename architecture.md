# Architecture — avant / après Vault

## Avant : secrets fragmentés et non chiffrés

Chaque application gère ses propres secrets de façon isolée — souvent stockés en clair dans des fichiers de configuration ou des variables d'environnement, sans rotation ni traçabilité centralisée.

```
[App Mobile Banking]  --(secrets en clair)-->  config.yml
[App Gestion de Flux]  --(secrets en clair)-->  .env
[App Gestion Interne]  --(secrets en clair)-->  settings.ini
```

**Risques :** fuite de clés en cas de compromission d'un seul fichier, aucune rotation automatique, aucun journal des accès.

## Après : coffre-fort centralisé Vault

Toutes les applications récupèrent dynamiquement leurs secrets via l'API Vault, authentifiées par un rôle dédié (AppRole), avec une politique ACL appliquant le principe du moindre privilège.

```
[App Mobile Banking] ─┐
[App Gestion de Flux] ─┼──► API Vault (TLS) ──► Coffre-fort chiffré (AES-256-GCM)
[App Gestion Interne] ─┘        │                     │
                                 │              Journal d'audit (HMAC)
                           Politiques ACL
                         (moindre privilège)
```

**Bénéfices :** point de passage unique et audité, rotation automatique des secrets, aucune exposition directe des bases de données, conformité réglementaire (ISO 27001).
