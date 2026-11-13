# Planning de permanence

Application en **un seul fichier HTML** (aucune installation, aucune pub) : chaque permanent crée son identifiant (nom + mot de passe) et déclare ses disponibilités **jour par jour via un calendrier cliquable** (indisponible par défaut, un clic rend le jour disponible, un second clic l'annule). Le mois se choisit avec les flèches ou les listes déroulantes. L'**admin voit l'ensemble des disponibilités** (calendrier récapitulatif, détail, export CSV, archivage JSON).

## Démarrage rapide (mode local, 1 minute)

1. Hébergez le dépôt sur **GitHub Pages** : *Settings → Pages → Source : branche `main`, dossier `/ (root)*.
2. Ouvrez l'URL `https://votre-compte.github.io/planning-permanence/`.

En **mode local**, les données sont enregistrées dans le navigateur (localStorage) : chaque permanent ne voit que **ses propres** disponibilités sur **son propre appareil**.

## Mode partagé (recommandé) : Supabase

Pour que tous les permanents partagent les mêmes données depuis n'importe quel appareil :

1. Créez un compte gratuit sur [supabase.com](https://supabase.com) (pas de carte bancaire).
2. Créez un projet, puis dans *SQL Editor*, exécutez le script `schema.sql` de ce dépôt.
3. Dans *Project Settings → API*, copiez l'**URL** et la **clé anon (public)**.
4. Collez-les dans **`config.js`** (à la racine) :
   ```js
   const SUPABASE_URL = "https://xxxx.supabase.co";
   const SUPABASE_ANON_KEY = "votre-clé-anon";
   ```
5. Déployez : l'application passe en **mode partagé**. Les clés vivent dans `config.js`, séparées du code — les mises à jour de `index.html` n'y touchent jamais.

## Comptes

- **Admin** : identifiant `admin`, mot de passe `1406` (intégré au code, fonctionne dans les deux modes). Il voit toutes les disponibilités (calendrier avec nombre de permanents disponibles par jour, détail filtrable, export CSV, sauvegarde JSON) et la liste des permanents.
- **Permanents** : créent leur identifiant (nom + mot de passe, conservé d'une visite à l'autre). Chacun **ne voit que ses propres disponibilités**, saisies en cliquant sur les jours du calendrier.

## Sécurité

Les mots de passe ne sont **jamais stockés en clair** (hachage SHA-256 + sel aléatoire). La clé anon Supabase est publique par conception ; les politiques RLS de `schema.sql` sont ouvertes car l'application gère elle-même ses comptes. Pour un besoin plus sensible, activez Supabase Auth et resserrez les politiques avec `auth.uid()`. Ne mettez jamais la clé `service_role` dans `config.js`.

## Schéma de données

| Table | Colonnes |
|---|---|
| `permanents` | `id`, `nom` (unique), `mdp_hash`, `salt`, `admin` |
| `dispos` | `id`, `permanent_id`, `date`, `creneau` (vaut `Journée`), `dispo`, `commentaire` |
