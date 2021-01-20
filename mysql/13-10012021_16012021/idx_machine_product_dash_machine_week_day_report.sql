alter table machine_product_dash drop column date_ref_year;
alter table machine_product_dash drop column date_ref_month;
alter table machine_product_dash drop column date_ref_week;
alter table machine_product_dash drop column date_ref_day;

alter table machine_product_dash add column date_ref_year int GENERATED ALWAYS AS (year(`inserted_at`)) STORED;
alter table machine_product_dash add column date_ref_month int GENERATED ALWAYS AS (month(`inserted_at`)) STORED;
alter table machine_product_dash add column date_ref_week int GENERATED ALWAYS AS (week(`inserted_at`, 5)) STORED;
alter table machine_product_dash add column date_ref_day int GENERATED ALWAYS AS (day(`inserted_at`)) STORED;

alter table machine_product_dash add index idx_machine_product_dash_machine_week_day_report(channel_id, machine_code, date_ref_year, date_ref_week);