create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  title text not null,
  content text not null,
  song_link text default '',
  photo text default '',
  created_at timestamptz not null default now()
);

create table if not exists public.album_photos (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  src text not null,
  created_at timestamptz not null default now()
);

alter table public.entries enable row level security;
alter table public.album_photos enable row level security;

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
