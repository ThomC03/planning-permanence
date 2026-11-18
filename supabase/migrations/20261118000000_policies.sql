-- Policies RLS rendues idempotentes : à exécuter dans le SQL Editor de Supabase.
-- Recrée toutes les policies existantes (utile si la base a été créée avant leur ajout,
-- notamment la suppression des permanents) et ajoute la suppression des plannings.

drop policy if exists "lecture des permanents" on permanents;
drop policy if exists "inscription" on permanents;
drop policy if exists "maj des permanents" on permanents;
drop policy if exists "suppression des permanents" on permanents;
create policy "lecture des permanents" on permanents for select using (true);
create policy "inscription" on permanents for insert with check (true);
create policy "maj des permanents" on permanents for update using (true);
create policy "suppression des permanents" on permanents for delete using (true);

drop policy if exists "lecture des dispos" on dispos;
drop policy if exists "ajout de dispos" on dispos;
drop policy if exists "suppression de dispos" on dispos;
create policy "lecture des dispos" on dispos for select using (true);
create policy "ajout de dispos" on dispos for insert with check (true);
create policy "suppression de dispos" on dispos for delete using (true);

drop policy if exists "lecture des besoins" on besoins;
drop policy if exists "maj des besoins" on besoins;
drop policy if exists "maj des besoins 2" on besoins;
create policy "lecture des besoins" on besoins for select using (true);
create policy "maj des besoins" on besoins for insert with check (true);
create policy "maj des besoins 2" on besoins for update using (true);

drop policy if exists "lecture des plannings" on plannings;
drop policy if exists "maj des plannings" on plannings;
drop policy if exists "maj des plannings 2" on plannings;
drop policy if exists "suppression des plannings" on plannings;
create policy "lecture des plannings" on plannings for select using (true);
create policy "maj des plannings" on plannings for insert with check (true);
create policy "maj des plannings 2" on plannings for update using (true);
create policy "suppression des plannings" on plannings for delete using (true);

drop policy if exists "lecture des verrous" on verrous;
drop policy if exists "ajout des verrous" on verrous;
drop policy if exists "maj des verrous" on verrous;
drop policy if exists "suppression des verrous" on verrous;
create policy "lecture des verrous" on verrous for select using (true);
create policy "ajout des verrous" on verrous for insert with check (true);
create policy "maj des verrous" on verrous for update using (true);
create policy "suppression des verrous" on verrous for delete using (true);
