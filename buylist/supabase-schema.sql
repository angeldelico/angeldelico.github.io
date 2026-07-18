-- ============================================================
--  FFX Buy List — Supabase schema
--  Run this in your project's SQL Editor:
--  https://supabase.com/dashboard/project/nllxqllzuxgkdpwzfvmx/sql
--
--  Access model: PASSCODE TO EDIT.
--   * Anyone can READ (the site is public).
--   * INSERT / UPDATE / DELETE require the request to carry an
--     "x-edit-pass" header equal to the passcode below.
--   * The passcode lives ONLY here in the database (never in the
--     public repo). Change EDIT_PASSCODE_HERE before running.
-- ============================================================

create extension if not exists pgcrypto;

-- ---------- tables ----------
create table if not exists public.people (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  position    int  not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists public.items (
  id          uuid primary key default gen_random_uuid(),
  person_id   uuid not null references public.people(id) on delete cascade,
  slug        text default '',          -- stable key for itinerary "buy along the way" chips (item1..item6)
  name        text not null,
  price       text default '',
  twd         text default '',
  price_note  text default '',
  meta        text default '',
  where_rows  jsonb not null default '[]'::jsonb,
  warn        text default '',
  image       text default '',
  link        text default '',
  badge_cls   text default '',
  badge_text  text default '',
  bought      boolean not null default false,
  position    int  not null default 0,
  created_at  timestamptz not null default now()
);
create index if not exists items_person_idx on public.items(person_id);

create table if not exists public.trip_days (
  id          uuid primary key default gen_random_uuid(),
  date_label  text not null,
  place       text default '',
  src         text default '',
  hotel       text default '',
  hotelq      text default '',
  buystrip    jsonb,
  position    int  not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists public.trip_spots (
  id          uuid primary key default gen_random_uuid(),
  day_id      uuid not null references public.trip_days(id) on delete cascade,
  name        text not null,
  q           text default '',
  wiki        text default '',
  emoji       text default '📍',
  sub         text default '',
  tag         text default '',
  skip        boolean not null default false,
  position    int  not null default 0,
  created_at  timestamptz not null default now()
);
create index if not exists trip_spots_day_idx on public.trip_spots(day_id);

-- ---------- passcode check (reads the x-edit-pass request header) ----------
-- 🔑 CHANGE THE PASSCODE on the next line, then run this whole file.
create or replace function public.edit_ok() returns boolean
language sql stable as $$
  select coalesce(current_setting('request.headers', true)::json ->> 'x-edit-pass', '')
         = 'EDIT_PASSCODE_HERE';
$$;

-- ---------- Row Level Security ----------
alter table public.people     enable row level security;
alter table public.items      enable row level security;
alter table public.trip_days  enable row level security;
alter table public.trip_spots enable row level security;

-- read for everyone; writes only with the correct passcode header
do $$
declare t text;
begin
  foreach t in array array['people','items','trip_days','trip_spots'] loop
    execute format('drop policy if exists read_all  on public.%I', t);
    execute format('drop policy if exists ins_pass  on public.%I', t);
    execute format('drop policy if exists upd_pass  on public.%I', t);
    execute format('drop policy if exists del_pass  on public.%I', t);
    execute format('create policy read_all on public.%I for select using (true)', t);
    execute format('create policy ins_pass on public.%I for insert with check (public.edit_ok())', t);
    execute format('create policy upd_pass on public.%I for update using (public.edit_ok()) with check (public.edit_ok())', t);
    execute format('create policy del_pass on public.%I for delete using (public.edit_ok())', t);
  end loop;
end $$;

-- ---------- grants (anon = the public API role used by the site) ----------
grant usage on schema public to anon;
grant select, insert, update, delete on
  public.people, public.items, public.trip_days, public.trip_spots to anon;
grant execute on function public.edit_ok() to anon;

-- ---------- realtime (optional; enables live sync across devices) ----------
do $$
begin
  begin
    alter publication supabase_realtime add table
      public.people, public.items, public.trip_days, public.trip_spots;
  exception when duplicate_object then null;
  end;
end $$;

-- Tables start EMPTY. Open the site, unlock with your passcode, and use
-- the "⬆️ 一鍵匯入預設清單與行程" button to import Chris's 6 items and the
-- Day 1–10 itinerary. (Nothing is seeded here so re-running is safe.)
