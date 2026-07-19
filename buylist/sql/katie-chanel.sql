-- Katie: Chanel 福袋包 S26
-- 在 Supabase → SQL Editor 貼上整段按 Run（不需要密碼；三段皆可重複執行）。
-- 註：不確定「S26 福袋包」的確切款式與定價，故未填價格，現場為準。

-- 1) 擴充 Katie 的 Chanel 物品（用「福袋」比對）
update public.items set
  slug       = 'katie-chanel',
  name       = 'Chanel（香奈兒）福袋包 S26',
  where_rows = to_jsonb(array[
    'Chanel 大阪：心齋橋 CHANEL 精品店，或阪急うめだ本店／大丸心斎橋／髙島屋大阪 內專櫃（可辦免税）',
    'Chanel 神戸：旧居留地・大丸神戸周邊（Day 2–3 順路可先問，早買早安心）',
    'Chanel 京都：京都髙島屋／大丸京都 專櫃（Day 8 順路）',
    '熱門／新季包款常缺貨或需登記候補；建議先電話或現場確認 S26 該款是否有現貨、可否購入'
  ]),
  meta       = 'Chanel 手袋屬限量精品，新季／熱門款常需候補或限購，各分店庫存差異大。攜護照可辦免税（消費税約 10%）。',
  warn       = '⚠️ 這款的確切型號與定價我不確定，沒有亂寫價格——以專櫃現場為準。想穩拿建議行前先聯絡分店確認有無現貨。',
  badge_cls  = 'limited',
  badge_text = '精品・限量'
where person_id = (select id from public.people where name = 'Katie' limit 1)
  and name ilike '%福袋%';

-- 2) Day 10（大阪）新增店家地點（不用別名，可重跑）
insert into public.trip_spots (day_id, name, q, wiki, emoji, sub, tag, skip, position)
select
  (select id from public.trip_days where date_label like '%Day 10%' limit 1),
  'CHANEL 大阪（心齋橋）', 'CHANEL 心斎橋', '', '👜', 'Katie：Chanel 福袋包 S26', '', false,
  coalesce((select max(position) + 1 from public.trip_spots
            where day_id = (select id from public.trip_days where date_label like '%Day 10%' limit 1)), 0)
where not exists (
  select 1 from public.trip_spots
  where name = 'CHANEL 大阪（心齋橋）'
    and day_id = (select id from public.trip_days where date_label like '%Day 10%' limit 1)
);

-- 3) 在 Day 2 / Day 8 / Day 10 的「沿途先買」都加一個 Katie 標籤（可重跑）
update public.trip_days set
  buystrip = jsonb_set(buystrip, '{chips}',
    (buystrip->'chips') || jsonb_build_array(
      jsonb_build_object('item','katie-chanel','em','👜','label','Katie：Chanel')))
where buystrip is not null
  and (date_label like '%Day 2%' or date_label like '%Day 8%' or date_label like '%Day 10%')
  and not (buystrip->'chips' @> jsonb_build_array(jsonb_build_object('item','katie-chanel')));
