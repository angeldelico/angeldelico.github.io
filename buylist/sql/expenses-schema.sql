-- 旅費（expenses）資料表 — 在 Supabase → SQL Editor 貼上按 Run（跑一次即可）。
-- 需先跑過主 schema（buylist/supabase-schema.sql），因為這裡沿用 edit_ok() 密碼判斷。

create table if not exists public.expenses (
  id           uuid primary key default gen_random_uuid(),
  kind         text not null default 'expense',       -- 'expense' 一般消費 | 'payment' 還款
  description  text default '',
  amount       numeric not null default 0,
  currency     text not null default 'JPY',           -- 'JPY' | 'TWD'
  payer_id     uuid references public.people(id) on delete set null,
  participants jsonb not null default '[]'::jsonb,     -- 分攤的人 people.id 陣列（平均分）
  spent_on     date,
  position     int  not null default 0,
  created_at   timestamptz not null default now()
);

alter table public.expenses enable row level security;
drop policy if exists read_all on public.expenses;
drop policy if exists ins_pass on public.expenses;
drop policy if exists upd_pass on public.expenses;
drop policy if exists del_pass on public.expenses;
create policy read_all on public.expenses for select using (true);
create policy ins_pass on public.expenses for insert with check (public.edit_ok());
create policy upd_pass on public.expenses for update using (public.edit_ok()) with check (public.edit_ok());
create policy del_pass on public.expenses for delete using (public.edit_ok());

grant select, insert, update, delete on public.expenses to anon;

do $$
begin
  begin
    alter publication supabase_realtime add table public.expenses;
  exception when duplicate_object then null;
  end;
end $$;
