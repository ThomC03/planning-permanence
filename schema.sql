create table permanents (
  id uuid primary key default gen_random_uuid(),
  nom text not null unique,
  mdp_hash text not null,
  salt text not null,
  admin boolean not null default false,
  created_at timestamptz not null default now()
);

create table dispos (
  id uuid primary key default gen_random_uuid(),
  permanent_id uuid not null references permanents(id) on delete cascade,
  date date not null,
  creneau text not null,
  dispo boolean not null default true,
  commentaire text default '',
  created_at timestamptz not null default now()
);

create index dispos_permanent_idx on dispos(permanent_id);
create index dispos_date_idx on dispos(date);

alter table permanents enable row level security;
alter table dispos enable row level security;

create policy "lecture des permanents" on permanents for select using (true);
create policy "inscription" on permanents for insert with check (true);
create policy "maj du role admin" on permanents for update using (true);
create policy "lecture des dispos" on dispos for select using (true);
create policy "ajout de dispos" on dispos for insert with check (true);
create policy "suppression de dispos" on dispos for delete using (true);
