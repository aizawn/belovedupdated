create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  title text not null,
  content text not null,
  song_link text default '',
  photo text default '',
  author_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.entries
  add column if not exists song_link text default '',
  add column if not exists photo text default '',
  add column if not exists author_id uuid references auth.users(id) on delete set null;

create table if not exists public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.album_photos (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  src text not null,
  author_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.album_photos
  add column if not exists author_id uuid references auth.users(id) on delete set null;

create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  message text not null check (char_length(message) between 1 and 1000),
  author_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.chat_messages
  add column if not exists author_id uuid references auth.users(id) on delete set null;

create table if not exists public.entry_comments (
  id uuid primary key default gen_random_uuid(),
  entry_id uuid not null references public.entries(id) on delete cascade,
  message text not null check (char_length(message) between 1 and 1000),
  author_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.entry_comments
  add column if not exists author_id uuid references auth.users(id) on delete set null;

alter table public.entries enable row level security;
alter table public.user_profiles enable row level security;
alter table public.album_photos enable row level security;
alter table public.chat_messages enable row level security;
alter table public.entry_comments enable row level security;

drop policy if exists "authenticated users can read user profiles" on public.user_profiles;
drop policy if exists "users can create their own profile" on public.user_profiles;
drop policy if exists "users can update their own profile" on public.user_profiles;

create policy "authenticated users can read user profiles"
  on public.user_profiles for select to authenticated using (true);
create policy "users can create their own profile"
  on public.user_profiles for insert to authenticated with check (id = auth.uid());
create policy "users can update their own profile"
  on public.user_profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "authenticated users can read entries" on public.entries;
drop policy if exists "authenticated users can add entries" on public.entries;
drop policy if exists "authenticated users can update entries" on public.entries;
drop policy if exists "authenticated users can delete entries" on public.entries;
drop policy if exists "authenticated users can read album photos" on public.album_photos;
drop policy if exists "authenticated users can add album photos" on public.album_photos;
drop policy if exists "authenticated users can delete album photos" on public.album_photos;
drop policy if exists "authenticated users can read chat messages" on public.chat_messages;
drop policy if exists "authenticated users can add chat messages" on public.chat_messages;
drop policy if exists "authenticated users can delete chat messages" on public.chat_messages;
drop policy if exists "authenticated users can read entry comments" on public.entry_comments;
drop policy if exists "authenticated users can add entry comments" on public.entry_comments;
drop policy if exists "authenticated users can delete entry comments" on public.entry_comments;

create policy "authenticated users can read entries"
  on public.entries for select to authenticated using (true);
create policy "authenticated users can add entries"
  on public.entries for insert to authenticated with check (author_id = auth.uid());
create policy "authenticated users can update entries"
  on public.entries for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());
create policy "authenticated users can delete entries"
  on public.entries for delete to authenticated using (author_id = auth.uid());

create policy "authenticated users can read album photos"
  on public.album_photos for select to authenticated using (true);
create policy "authenticated users can add album photos"
  on public.album_photos for insert to authenticated with check (author_id = auth.uid());
create policy "authenticated users can delete album photos"
  on public.album_photos for delete to authenticated using (author_id = auth.uid());

create policy "authenticated users can read chat messages"
  on public.chat_messages for select to authenticated using (true);
create policy "authenticated users can add chat messages"
  on public.chat_messages for insert to authenticated with check (author_id = auth.uid());
create policy "authenticated users can delete chat messages"
  on public.chat_messages for delete to authenticated using (author_id = auth.uid());

create policy "authenticated users can read entry comments"
  on public.entry_comments for select to authenticated using (true);
create policy "authenticated users can add entry comments"
  on public.entry_comments for insert to authenticated with check (author_id = auth.uid());
create policy "authenticated users can delete entry comments"
  on public.entry_comments for delete to authenticated using (author_id = auth.uid());

do $$
begin
  alter publication supabase_realtime add table public.chat_messages;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.entries;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.album_photos;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.entry_comments;
exception
  when duplicate_object then null;
end $$;

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
