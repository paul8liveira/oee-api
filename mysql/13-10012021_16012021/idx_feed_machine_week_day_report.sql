alter table feed add column inserted_at_year int GENERATED ALWAYS AS (year(`inserted_at`)) STORED;
alter table feed add column inserted_at_week int GENERATED ALWAYS AS (week(`inserted_at`, 5)) STORED;

alter table feed add index idx_feed_machine_week_day_report(ch_id, mc_cd, inserted_at_year, inserted_at_week);