# Planning de permanence

Outil web (une seule page `index.html` + Supabase) pour établir le planning de permanence d'une boutique.

## Workflow

1. **Admin** — onglet « Boutique » : cliquez sur un jour pour faire défiler `1 personne → 2 personnes → fermé → 1 personne…`.
2. **Chaque permanent** — onglet « Disponibilités » : il ne voit que son propre calendrier (les choix de l'admin y sont affichés : 1 pers. / 2 pers. / Fermé) et peut verrouiller son mois quand il est sûr de lui.
3. **Admin** — « Générer le planning » (en haut) : le solveur respecte les jours fermés (personne de permanence), les contraintes de chacun (week-ends, jours consécutifs, max/mois) et propose plusieurs alternatives triées par équité. L'admin choisit la solution qui lui convient et l'enregistre (« Enregistrer ce planning »).
4. **Admin** — onglet « Contraintes » : administrer les comptes (renommer, mot de passe, verrouiller/déverrouiller, tout verrouiller d'un coup, supprimer un compte en tapant son nom) et **verrouiller toutes les disponibilités du mois** avant diffusion.
5. **Tous** — onglet « Planning » : le planning publié (lecture seule, avec date de publication), export PDF possible.

Navigation dans les calendriers : flèches `‹ ›` autour du mois, bouton « Aujourd'hui », clic sur le libellé du mois pour choisir un mois précis.

## Déploiement

- Hébergement statique (ex. Vercel) : servir la racine du dépôt (`index.html` + `config.js`).
- Renseigner `SUPABASE_URL` et `SUPABASE_ANON_KEY` dans `config.js` (clé « anon » publique par conception ; ne JAMAIS y mettre la clé `service_role`).
- Sans Supabase renseigné, l'app fonctionne en mode local (localStorage du navigateur).

## Base de données (Supabase)

- Nouveau projet : exécuter `supabase/migrations/20261113231309_init.sql`.
- **Mise à jour d'une base existante** : exécuter dans le SQL Editor `supabase/migrations/20261118000000_policies.sql` (idempotent — recrée toutes les policies RLS, dont la suppression des permanents et des plannings, indispensable au bouton « Supprimer » de l'admin).

## Tests

```bash
node tests/solveur.test.js
```

## Note sécurité

Les policies RLS sont en `using (true)` (auth custom par hash, sans Supabase Auth) : la clé anon permet techniquement toute écriture/suppression. Durcissement à prévoir via Edge Functions (service role).
