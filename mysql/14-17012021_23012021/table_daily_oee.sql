create table daily_oee (
	id int not null auto_increment primary key,
	channel_id int(11) not null,
	machine_code varchar(10) not null,
	machine_name varchar(500) not null,
    production float,
    availability float,
    performance float,
    quality float,
    oee float,
    year int not null,
    month int not null,
    week int not null,
    day int not null,
    inserted_at timestamp not null default current_timestamp
);
alter table daily_oee add index idx_channel_machine_year_week(channel_id, machine_code, year, week);