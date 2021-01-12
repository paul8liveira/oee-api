alter table machine_pause_dash drop column date_ref_year;
alter table machine_pause_dash drop column date_ref_month;
alter table machine_pause_dash drop column date_ref_day;

alter table machine_pause_dash add column date_ref_year int GENERATED ALWAYS AS (year(`date_ref`)) STORED;
alter table machine_pause_dash add column date_ref_month int GENERATED ALWAYS AS (month(`date_ref`)) STORED;
alter table machine_pause_dash add column date_ref_week int GENERATED ALWAYS AS (week(`date_ref`, 5)) STORED;
alter table machine_pause_dash add column date_ref_day int GENERATED ALWAYS AS (day(`date_ref`)) STORED;


alter table machine_pause_dash add index idx_machine_pause_dash_machine_week_day_report(channel_id, machine_code, date_ref_year, date_ref_week, insert_index);