# Planning de permanence

Application en **un seul fichier HTML** (aucune installation, aucune pub) avec sauvegarde partagée via Supabase. **Version courante : TC2** (affichée en bas de page).

- Chaque permanent crée son **identifiant unique** (nom + mot de passe) et déclare ses disponibilités **jour par jour** sur un calendrier cliquable (par défaut aucun jour disponible, un clic = disponible, un second clic = annulation).
- **Verrouillage** : le permanent peut verrouiller ses disponibilités du mois choisi ; il ne peut alors plus les modifier (seul l'admin le peut à tout moment).
- L'**admin** (identifiant `admin`) accède à tout : besoins de la boutique (1 / 2 personnes / fermé), disponibilités et contraintes de chacun, administration des comptes (renommer, réinitialiser mot de passe, supprimer, verrouiller/déverrouiller), génération du planning.
- Le **générateur de planning** propose plusieurs solutions alternatives triées de la plus équitable à la moins équitable, en respectant les besoins de la boutique et les contraintes individuelles :
  - Pas de week-end
  - Uniquement week-end
  - Au moins 1 week-end
  - 2 jours consécutifs
  - Maximum de jours dans le mois (champ de saisie)
- **Plannings persistants** : l'admin enregistre la solution choisie pour un mois ; elle apparaît dans l'onglet **Planning**, visible par tous en lecture seule, avec tous les mois planifiés consultables. Un bouton permet de régénérer un planning existant.
- **Export PDF** : uniquement le calendrier du planning choisi et l'image `logo.png` (à déposer à la racine du dépôt) — aucune autre information.
- Interface adaptée à la saisie sur **mobile**.

## Démarrage rapide (mode local, 1 minute)

1. Hébergez le dépôt sur **GitHub Pages** : *Settings → Pages → Source : branche `main`, dossier `/ (root)*.
2. Ouvrez l'URL `https://votre-compte.github.io/planning-permanence/`.

En **mode local**, les données restent dans le navigateur (chaque appareil a ses propres données). Pour partager les données entre tous les permanents, passez en mode Supabase ci-dessous.

## Tester sur sa machine (développement)

```bash
cd planning-permanence
python3 -m http.server 8000
```
Puis ouvrez <http://localhost:8000>. Aucune installation nécessaire ; le mode local fonctionne sans Supabase.

## Mode partagé : Supabase

1. Créez un compte gratuit sur [supabase.com](https://supabase.com) (pas de carte bancaire).
2. Créez un projet, puis dans *SQL Editor* :
   - si la base est **vide**, exécutez `schema.sql` en entier ;
   - si la base d'une **version précédente** existe déjà, exécutez uniquement le bloc `MISE À JOUR` commenté en bas de `schema.sql` (ajoute les colonnes de contraintes et les tables `besoins`, `plannings`, `verrous`).
3. Dans *Project Settings → API*, copiez l'**URL** et la **clé anon (public)**.
4. Collez-les dans **`config.js`** (à la racine) :
   ```js
   const SUPABASE_URL = "https://xxxx.supabase.co";
   const SUPABASE_ANON_KEY = "votre-clé-anon";
   ```
5. Déployez : l'application passe en **mode partagé**. Les clés vivent dans `config.js`, séparées du code — les mises à jour de `index.html` n'y touchent jamais.

## Comptes

| Rôle | Accès |
|---|---|
| **Admin** (`admin` / mot de passe intégré) | Boutique, toutes les disponibilités, contraintes, administration des comptes, génération/enregistrement des plannings, régénération, export PDF |
| **Permanent** (compte créé par lui-même) | Ses disponibilités (+ verrouillage par mois), son commentaire, consultation de l'onglet Planning (lecture seule) |

## Sécurité

Les mots de passe ne sont jamais stockés en clair (SHA-256 + sel aléatoire). La clé anon Supabase est publique par conception ; les politiques RLS de `schema.sql` sont ouvertes car l'application gère elle-même ses comptes. Ne mettez jamais la clé `service_role` dans `config.js`.

## Tests

`tests/solveur.test.js` vérifie localement le solveur (contraintes, besoins de la boutique, équité, détection d'impossibilité) :

```bash
node tests/solveur.test.js
```

## Schéma de données

| Table | Colonnes |
|---|---|
| `permanents` | `id`, `nom` (unique), `mdp_hash`, `salt`, `admin`, `no_we`, `only_we`, `min_we`, `paired`, `max_days`, `commentaire` |
| `dispos` | `id`, `permanent_id`, `date`, `creneau`, `dispo`, `commentaire` |
| `besoins` | `date` (unique), `valeur` (0 = fermé, 1 ou 2 personnes) |
| `plannings` | `mois` (unique, ex. `2025-11`), `contenu` (solution choisie) |
| `verrous` | `permanent_id`, `mois` (verrouillage des disponibilités) |
