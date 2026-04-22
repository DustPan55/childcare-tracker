-- Childcare Tracker schema
-- Run this once in Supabase SQL Editor: Dashboard → SQL Editor → New query → paste → Run

create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  start_at timestamptz not null,
  end_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists public.daycare_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  drop_off time,
  pick_up time,
  supplies text[] default '{}',
  flags text[] default '{}',
  notes text default '',
  created_at timestamptz default now()
);

create table if not exists public.settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  rate numeric(10,2) default 0,
  sitter_name text default '',
  daycare_name text default '',
  updated_at timestamptz default now()
);

create index if not exists sessions_user_start_idx on public.sessions (user_id, start_at desc);
create index if not exists daycare_user_date_idx on public.daycare_entries (user_id, date desc);

alter table public.sessions enable row level security;
alter table public.daycare_entries enable row level security;
alter table public.settings enable row level security;

drop policy if exists "own sessions" on public.sessions;
create policy "own sessions" on public.sessions for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own daycare" on public.daycare_entries;
create policy "own daycare" on public.daycare_entries for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own settings" on public.settings;
create policy "own settings" on public.settings for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
