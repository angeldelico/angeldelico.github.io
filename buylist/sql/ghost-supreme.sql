-- Ghost: Supreme 輪架 @ Supreme 大阪（南堀江）
-- 在 Supabase → SQL Editor 貼上整段按 Run（走 SQL 不需要密碼，三段皆可重複執行）。

-- 1) 擴充 Ghost 的「Supreme 輪架」細節（用名稱比對）
update public.items set
  slug       = 'ghost-supreme',
  where_rows = to_jsonb(array[
    'Supreme 大阪（關西唯一門市）— 大阪市西区南堀江 1-9-8，近難波・心齋橋',
    '只在實體店販售的 in-store 商品；官方線上 supremenewyork.com 日本發售日不定'
  ]),
  meta       = 'Supreme 大阪店位於南堀江服飾精品街，是關西唯一門市。發售日與週末人潮最多、常需排隊；限量配件售完不補。',
  warn       = '🕙 建議平日前往避開排隊；出發前用地圖確認營業時間與店休日。輪架屬店內商品，遇到就先拿。',
  badge_cls  = 'general',
  badge_text = '大阪限定・實體店'
where person_id = (select id from public.people where name = 'Ghost' limit 1)
  and name ilike '%supreme%';

-- 2) Day 10（大阪）新增店家地點（不用別名，可重跑）
insert into public.trip_spots (day_id, name, q, wiki, emoji, sub, tag, skip, position)
select
  (select id from public.trip_days where date_label like '%Day 10%' limit 1),
  'Supreme 大阪（南堀江）', 'Supreme Osaka 南堀江', '', '🧢', 'Ghost：Supreme 輪架', '', false,
  coalesce((select max(position) + 1 from public.trip_spots
            where day_id = (select id from public.trip_days where date_label like '%Day 10%' limit 1)), 0)
where not exists (
  select 1 from public.trip_spots
  where name = 'Supreme 大阪（南堀江）'
    and day_id = (select id from public.trip_days where date_label like '%Day 10%' limit 1)
);

-- 3) Day 10「沿途先買」加一個 Ghost 標籤，點了跳到該物品（可重跑）
update public.trip_days set
  buystrip = jsonb_set(buystrip, '{chips}',
    (buystrip->'chips') || jsonb_build_array(
      jsonb_build_object('item','ghost-supreme','em','🧢','label','Ghost：Supreme 輪架')))
where date_label like '%Day 10%'
  and buystrip is not null
  and not (buystrip->'chips' @> jsonb_build_array(jsonb_build_object('item','ghost-supreme')));
