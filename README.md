# Planning de permanence

Application en **un seul fichier HTML** (aucune installation, aucune pub) : chaque permanent crée son identifiant (nom + mot de passe), déclare ses disponibilités par date et créneau (Matin / Après-midi / Soir), et les sauvegarde. L'**admin voit toutes les disponibilités**, peut les filtrer, les exporter en CSV et archiver les données en JSON.

## Démarrage rapide (mode local, 1 minute)

1. Hébergez `index.html` sur **GitHub Pages** : dans votre dépôt → *Settings → Pages → Source : branche `main`, dossier `/ (root)*.
2. Ouvrez l'URL `https://votre-compte.github.io/planning-permanence/`.

En **mode local**, les données sont enregistrées dans le navigateur (localStorage) : chaque permanent ne voit que **ses propres** données sur **son propre appareil**. Le premier compte créé devient automatiquement **admin**.

## Mode partagé (recommandé) : Supabase

Pour que tous les permanents partagent les mêmes données depuis n'importe quel appareil :

1. Créez un compte gratuit sur [supabase.com](https://supabase.com) (pas de carte bancaire).
2. Créez un projet, puis dans *SQL Editor*, exécutez le script `schema.sql` de ce dépôt.
3. Dans *Project Settings → API*, copiez l'**URL** et la **clé anon (public)**.
4. Dans `index.html`, renseignez en haut du script :
   ```js
   const SUPABASE_URL = "https://xxxx.supabase.co";
   const SUPABASE_ANON_KEY = "votre-clé-anon";
   ```
5. Redéployez sur GitHub Pages : l'application passe en **mode partagé**.

### Rôles

- **Permanent** : crée son identifiant (nom + mot de passe, conservé d'une visite à l'autre), saisit et supprime ses disponibilités.
- **Admin** : voit toutes les disponibilités, la liste des permanents, exporte en CSV, sauvegarde/restaure en JSON. Pour promouvoir un compte, dans Supabase : `UPDATE permanents SET admin = true WHERE nom = 'Prénom';`

### Sécurité

Les mots de passe ne sont **jamais stockés en clair** (hachage SHA-256 + sel aléatoire). La clé anon Supabase est publique par conception ; elle autorise la lecture et l'écriture des lignes (les politiques RLS de `schema.sql` sont volontairement ouvertes car l'application gère elle-même ses comptes). Ce montage convient à un usage associatif simple ; pour un besoin plus sensible, activez Supabase Auth et resserrez les politiques avec `auth.uid()`.

## Schéma de données

| Table | Colonnes |
|---|---|
| `permanents` | `id`, `nom` (unique), `mdp_hash`, `salt`, `admin` |
| `dispos` | `id`, `permanent_id`, `date`, `creneau`, `dispo`, `commentaire` |
