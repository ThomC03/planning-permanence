# Planning de permanence

Application en **un seul fichier HTML** (aucune installation, aucune pub) avec sauvegarde partagée via Supabase.

- Chaque permanent crée son **identifiant unique** (nom + mot de passe) et déclare ses disponibilités **jour par jour** sur un calendrier cliquable (aucun jour disponible par défaut, un clic = disponible, un second clic = annulation).
- L'**admin** (identifiant `admin`) accède à tout : besoins de la boutique (1 personne / 2 personnes / fermé par jour), disponibilités et contraintes de chaque permanent, génération automatique du planning, export CSV / JSON / PDF.
- Le **générateur de planning** produit plusieurs solutions alternatives, triées de la plus équitable à la moins équitable, en respectant les besoins de la boutique et les contraintes individuelles :
  - Pas de week-end
  - Uniquement week-end
  - Au moins 1 week-end
  - 2 jours consécutifs
  - Maximum de jours dans le mois (champ de saisie)

## Démarrage rapide (mode local, 1 minute)

1. Hébergez le dépôt sur **GitHub Pages** : *Settings → Pages → Source : branche `main`, dossier `/ (root)*.
2. Ouvrez l'URL `https://votre-compte.github.io/planning-permanence/`.

En **mode local**, les données restent dans le navigateur (chaque appareil a ses propres données). Pour partager les données entre tous les permanents, passez en mode Supabase ci-dessous.

## Mode partagé : Supabase

1. Créez un compte gratuit sur [supabase.com](https://supabase.com) (pas de carte bancaire).
2. Créez un projet, puis dans *SQL Editor* :
   - si la base est **vide**, exécutez `schema.sql` en entier ;
   - si la base de la **version précédente** existe déjà, exécutez uniquement le bloc `MISE À JOUR` commenté en bas de `schema.sql` (ajoute les colonnes de contraintes et la table `besoins`).
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
| **Admin** (`admin` / mot de passe intégré) | Onglets Boutique, Disponibilités (tous les permanents), Contraintes, Résultat (génération, exports CSV/JSON/PDF) |
| **Permanent** (compte créé par lui-même) | Uniquement ses disponibilités et son commentaire — il ne voit jamais celles des autres |

## Sécurité

Les mots de passe ne sont jamais stockés en clair (SHA-256 + sel aléatoire). La clé anon Supabase est publique par conception ; les politiques RLS de `schema.sql` sont ouvertes car l'application gère elle-même ses comptes. Ne mettez jamais la clé `service_role` dans `config.js`.

## Schéma de données

| Table | Colonnes |
|---|---|
| `permanents` | `id`, `nom` (unique), `mdp_hash`, `salt`, `admin`, `no_we`, `only_we`, `min_we`, `paired`, `max_days`, `commentaire` |
| `dispos` | `id`, `permanent_id`, `date`, `creneau`, `dispo`, `commentaire` |
| `besoins` | `date` (unique), `valeur` (0 = fermé, 1 ou 2 personnes) |
