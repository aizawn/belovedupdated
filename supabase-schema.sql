create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  title text not null,
  content text not null,
  song_link text default '',
  photo text default '',
  created_at timestamptz not null default now()
);

alter table public.entries
  add column if not exists song_link text default '',
  add column if not exists photo text default '';

create table if not exists public.album_photos (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  src text not null,
  created_at timestamptz not null default now()
);

alter table public.entries enable row level security;
alter table public.album_photos enable row level security;

drop policy if exists "authenticated users can read entries" on public.entries;
drop policy if exists "authenticated users can add entries" on public.entries;
drop policy if exists "authenticated users can update entries" on public.entries;
drop policy if exists "authenticated users can delete entries" on public.entries;
drop policy if exists "authenticated users can read album photos" on public.album_photos;
drop policy if exists "authenticated users can add album photos" on public.album_photos;
drop policy if exists "authenticated users can delete album photos" on public.album_photos;

create policy "authenticated users can read entries"
  on public.entries for select to authenticated using (true);
create policy "authenticated users can add entries"
  on public.entries for insert to authenticated with check (true);
create policy "authenticated users can update entries"
  on public.entries for update to authenticated using (true) with check (true);
create policy "authenticated users can delete entries"
  on public.entries for delete to authenticated using (true);

create policy "authenticated users can read album photos"
  on public.album_photos for select to authenticated using (true);
create policy "authenticated users can add album photos"
  on public.album_photos for insert to authenticated with check (true);
create policy "authenticated users can delete album photos"
  on public.album_photos for delete to authenticated using (true);

insert into storage.buckets (id, name, public)
values
  ('entry-photos', 'entry-photos', true),
  ('album-photos', 'album-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "authenticated users can upload entry photos" on storage.objects;
drop policy if exists "authenticated users can read entry photos" on storage.objects;
drop policy if exists "authenticated users can update entry photos" on storage.objects;
drop policy if exists "authenticated users can delete entry photos" on storage.objects;
drop policy if exists "authenticated users can upload album photos" on storage.objects;
drop policy if exists "authenticated users can read album storage photos" on storage.objects;
drop policy if exists "authenticated users can update album storage photos" on storage.objects;
drop policy if exists "authenticated users can delete album storage photos" on storage.objects;

create policy "authenticated users can upload entry photos"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'entry-photos');

create policy "authenticated users can read entry photos"
  on storage.objects for select to authenticated
  using (bucket_id = 'entry-photos');

create policy "authenticated users can update entry photos"
  on storage.objects for update to authenticated
  using (bucket_id = 'entry-photos') with check (bucket_id = 'entry-photos');

create policy "authenticated users can delete entry photos"
  on storage.objects for delete to authenticated
  using (bucket_id = 'entry-photos');

create policy "authenticated users can upload album photos"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'album-photos');

create policy "authenticated users can read album storage photos"
  on storage.objects for select to authenticated
  using (bucket_id = 'album-photos');

create policy "authenticated users can update album storage photos"
  on storage.objects for update to authenticated
  using (bucket_id = 'album-photos') with check (bucket_id = 'album-photos');

create policy "authenticated users can delete album storage photos"
  on storage.objects for delete to authenticated
  using (bucket_id = 'album-photos');
