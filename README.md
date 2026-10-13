# 🔐 Vault Zero Trust Lab — Gestion centralisée des secrets

> Proof of Concept (PoC) de déploiement de **HashiCorp Vault** en haute disponibilité, conçu dans le cadre d'un mémoire de fin de cycle sur la sécurisation des secrets et mots de passe en environnement bancaire (modèle Zero Trust).

## 🎯 Contexte et objectif

Dans de nombreuses infrastructures en phase de digitalisation (notamment dans le secteur bancaire), les secrets applicatifs — mots de passe, clés d'API, identifiants de connexion aux bases de données — restent souvent stockés en clair dans des fichiers de configuration ou transmis par des canaux non chiffrés. Ce *Secret Sprawl* expose l'organisation à des risques critiques : fuite de données, usurpation d'identité, absence de traçabilité.

Ce projet démontre, via un laboratoire virtuel reproduisant une architecture bancaire type, comment **HashiCorp Vault** permet de :

- **Centraliser** tous les secrets dans un coffre-fort unique et chiffré
- **Chiffrer** les données au repos (AES-256-GCM) et en transit (TLS)
- **Tracer** chaque accès via un journal d'audit immuable
- **Faire tourner automatiquement** les identifiants (rotation des secrets)
- Appliquer le **principe du moindre privilège** via des politiques ACL granulaires

## 🏗️ Architecture

```
                    ┌─────────────┐
                    │   HAProxy    │   (répartiteur de charge)
                    │ Load Balancer│
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
  ┌─────▼─────┐      ┌─────▼─────┐      ┌─────▼─────┐
  │  vault-1   │      │  vault-2   │      │  vault-3   │
  │  (leader)  │◄────►│ (follower) │◄────►│ (follower) │
  └────────────┘      └────────────┘      └────────────┘
        Consensus Raft intégré (stockage + réplication)
```

**Stack technique :** Ubuntu Server · VMware Workstation · HashiCorp Vault (Community Edition) · Docker Compose · HAProxy · Protocole de consensus Raft

## 🔧 Déploiement — les 6 phases

| Phase | Étape | Commande clé |
|---|---|---|
| 1 | Installation & configuration du serveur Vault (TLS, stockage Raft, port 8200) | voir [`config/vault.hcl`](config/vault.hcl) |
| 2 | Initialisation & descellement (Shamir Secret Sharing, seuil 3/5 clés) | `vault operator init` |
| 3 | Activation du moteur de secrets KV v2 | `vault secrets enable -path=secret kv-v2` |
| 4 | Authentification (`userpass` + `AppRole`) et politiques ACL (moindre privilège) | voir [`policies/`](policies/) |
| 5 | Activation du dispositif d'audit (traçabilité complète) | `vault audit enable file file_path=/vault/logs/audit.log` |
| 6 | Cluster haute disponibilité (3 nœuds, Raft, failover testé) | voir [`docker-compose.yml`](docker-compose.yml) |

### Principe du moindre privilège (Shamir Secret Sharing)

L'initialisation du cluster génère **5 clés de descellement** ; il en faut **3 sur 5** pour déverrouiller le coffre-fort. Aucune personne seule ne peut donc accéder à l'ensemble des secrets — une application directe du modèle Zero Trust au niveau cryptographique.

### Politiques ACL par rôle applicatif

Chaque application ne reçoit accès qu'à ses propres secrets, via un rôle dédié (ex. `developer-policy.hcl`). Vault agit comme une couche d'intermédiation : il délivre ou révoque les identifiants **sans jamais exposer directement les bases de données sous-jacentes**.

### Audit & conformité

Chaque requête (lecture, écriture, authentification, révocation) est consignée dans un journal d'audit avec hachage HMAC des données sensibles — conforme aux exigences réglementaires du secteur bancaire (ISO 27001).

### Haute disponibilité

Cluster à 3 nœuds (Raft) + répartiteur HAProxy. Un test de tolérance aux pannes (arrêt volontaire du nœud leader) a confirmé l'élection automatique d'un nouveau leader sans interruption de service perceptible.

## 📁 Structure du dépôt

```
vault-zero-trust-lab/
├── README.md
├── docker-compose.yml        # Cluster Vault 3 nœuds + HAProxy
├── config/
│   └── vault.hcl             # Configuration serveur (TLS, Raft, audit)
├── policies/
│   └── developer-policy.hcl  # Exemple de politique ACL (moindre privilège)
└── docs/
    └── architecture.md       # Schéma avant/après Vault
```

## 📸 Captures d'écran

*(à ajouter : dashboard Vault, politique ACL appliquée, journal d'audit, test de rejet HTTP 403)*

## 📚 Contexte académique

Projet réalisé dans le cadre d'un mémoire de fin de cycle Licence (Administration des Systèmes d'Information), portant sur la sécurisation des mots de passe et secrets en entreprise via une architecture Zero Trust. L'environnement a été entièrement réalisé en laboratoire virtuel isolé (aucune intervention sur un système de production).

## 👤 Auteure

**HOUMALI Dopévi Arend** — Étudiante en cycle ingénieur informatique
📧 houmaliarend@gmail.com

---
*N'hésitez pas à ouvrir une issue ou une pull request pour toute question ou suggestion.*
