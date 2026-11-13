-- Schéma complet (nouveau projet) — si la base existe déjà, exécutez plutôt
-- le bloc "MISE À JOUR" en bas de ce fichier.

create table permanents (
  id uuid primary key default gen_random_uuid(),
  nom text not null unique,
  mdp_hash text not null,
  salt text not null,
  admin boolean not null default false,
  no_we boolean not null default false,
  only_we boolean not null default false,
  min_we boolean not null default false,
  paired boolean not null default false,
  max_days int not null default 0,
  commentaire text default '',
  created_at timestamptz not null default now()
);

create table dispos (
  id uuid primary key default gen_random_uuid(),
  permanent_id uuid not null references permanents(id) on delete cascade,
  date date not null,
  creneau text not null default 'Journée',
  dispo boolean not null default true,
  commentaire text default '',
  created_at timestamptz not null default now()
);

create table besoins (
  date date primary key,
  valeur int not null default 1
);

create table plannings (
  mois text primary key,
  contenu jsonb not null,
  updated_at timestamptz not null default now()
);

create table verrous (
  permanent_id uuid not null references permanents(id) on delete cascade,
  mois text not null,
  primary key (permanent_id, mois)
);

create index dispos_permanent_idx on dispos(permanent_id);
create index dispos_date_idx on dispos(date);

alter table permanents enable row level security;
alter table dispos enable row level security;
alter table besoins enable row level security;
alter table plannings enable row level security;
alter table verrous enable row level security;

create policy "lecture des permanents" on permanents for select using (true);
create policy "inscription" on permanents for insert with check (true);
create policy "maj des permanents" on permanents for update using (true);
create policy "suppression des permanents" on permanents for delete using (true);
create policy "lecture des dispos" on dispos for select using (true);
create policy "ajout de dispos" on dispos for insert with check (true);
create policy "suppression de dispos" on dispos for delete using (true);
create policy "lecture des besoins" on besoins for select using (true);
create policy "maj des besoins" on besoins for insert with check (true);
create policy "maj des besoins 2" on besoins for update using (true);
create policy "lecture des plannings" on plannings for select using (true);
create policy "maj des plannings" on plannings for insert with check (true);
create policy "maj des plannings 2" on plannings for update using (true);
create policy "lecture des verrous" on verrous for select using (true);
create policy "ajout des verrous" on verrous for insert with check (true);
create policy "maj des verrous" on verrous for update using (true);
create policy "suppression des verrous" on verrous for delete using (true);

-- ====== MISE À JOUR (si la base d'une version précédente existe déjà) ======
-- Exécutez uniquement ce bloc dans le SQL Editor :
--
-- alter table permanents
--   add column if not exists no_we boolean not null default false,
--   add column if not exists only_we boolean not null default false,
--   add column if not exists min_we boolean not null default false,
--   add column if not exists paired boolean not null default false,
--   add column if not exists max_days int not null default 0,
--   add column if not exists commentaire text default '';
--
-- create table if not exists besoins (
--   date date primary key,
--   valeur int not null default 1
-- );
-- alter table besoins enable row level security;
-- create policy "lecture des besoins" on besoins for select using (true);
-- create policy "maj des besoins" on besoins for insert with check (true);
-- create policy "maj des besoins 2" on besoins for update using (true);
--
-- create table if not exists plannings (
--   mois text primary key,
--   contenu jsonb not null,
--   updated_at timestamptz not null default now()
-- );
-- alter table plannings enable row level security;
-- create policy "lecture des plannings" on plannings for select using (true);
-- create policy "maj des plannings" on plannings for insert with check (true);
-- create policy "maj des plannings 2" on plannings for update using (true);
--
-- create table if not exists verrous (
--   permanent_id uuid not null references permanents(id) on delete cascade,
--   mois text not null,
--   primary key (permanent_id, mois)
-- );
-- alter table verrous enable row level security;
-- create policy "lecture des verrous" on verrous for select using (true);
-- create policy "ajout des verrous" on verrous for insert with check (true);
-- create policy "maj des verrous" on verrous for update using (true);
-- create policy "suppression des verrous" on verrous for delete using (true);
