-- SelvWallet prod stats for sketchybar (plugins/selv.sh). Read-only.
-- created_at columns are UTC "timestamp without time zone"; days are bucketed
-- in the local timezone (passed as :'tz'). "Active" = distinct users who sent
-- a transaction that day: last_login_at is only written at signup, so sending
-- is the only real usage signal the DB has.
begin read only;
set local app.system_access = 'monitoring';
select set_config('timezone', :'tz', true);

with sw as (
  select user_id, coalesce(addresses->'solana'->>'address', addresses->>'solana') sol
  from wallets
),
u as (select (created_at at time zone 'UTC')::date d from users),
tx as (
  select sw.user_id, (t.created_at at time zone 'UTC')::date d
  from transactions t left join sw on sw.sol = t.from_address
),
days as (select generate_series(current_date - 13, current_date, '1 day')::date d)
select json_build_object(
  'users',      (select count(*) from u),
  'wallets',    (select count(distinct user_id) from wallets),
  'senders',    (select count(distinct user_id) from tx),
  'tx',         (select count(*) from tx),
  'su_today',   (select count(*) from u where d = current_date),
  'su_yday',    (select count(*) from u where d = current_date - 1),
  'su_7',       (select count(*) from u where d > current_date - 7),
  'su_30',      (select count(*) from u where d > current_date - 30),
  'act_today',  (select count(distinct user_id) from tx where d = current_date),
  'act_yday',   (select count(distinct user_id) from tx where d = current_date - 1),
  'act_7',      (select count(distinct user_id) from tx where d > current_date - 7),
  'act_30',     (select count(distinct user_id) from tx where d > current_date - 30),
  'tx_today',   (select count(*) from tx where d = current_date),
  'tx_7',       (select count(*) from tx where d > current_date - 7),
  'tx_30',      (select count(*) from tx where d > current_date - 30),
  'su_series',  (select json_agg((select count(*) from u where u.d = days.d) order by days.d) from days),
  'act_series', (select json_agg((select count(distinct user_id) from tx where tx.d = days.d) order by days.d) from days)
);

rollback;
