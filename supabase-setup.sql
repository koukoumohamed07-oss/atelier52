-- Atelier M2 : base de données partagée (à coller dans Supabase > SQL Editor > Run)

create table if not exists site_public  (id text primary key, data jsonb not null default '{}');
create table if not exists site_private (id text primary key, data jsonb not null default '{}');
create table if not exists leads (id text primary key, data jsonb not null, created_at timestamptz default now());

alter table site_public  enable row level security;
alter table site_private enable row level security;
alter table leads        enable row level security;

-- Contenu du site : tout le monde lit, seuls les admins modifient
create policy "public lit le site"   on site_public for select using (true);
create policy "admin ecrit le site"  on site_public for all to authenticated using (true) with check (true);

-- Données privées (clients, statuts, ICE/RC/RIB) : admins seulement
create policy "admin prive" on site_private for all to authenticated using (true) with check (true);

-- Formulaires : tout visiteur peut envoyer, seuls les admins lisent / suppriment
create policy "visiteur envoie" on leads for insert to anon, authenticated with check (true);
create policy "admin lit"       on leads for select to authenticated using (true);
create policy "admin supprime"  on leads for delete to authenticated using (true);

-- Photos du site
insert into storage.buckets (id, name, public) values ('site', 'site', true) on conflict (id) do nothing;
create policy "admin envoie photos"   on storage.objects for insert to authenticated with check (bucket_id = 'site');
create policy "admin supprime photos" on storage.objects for delete to authenticated using (bucket_id = 'site');
