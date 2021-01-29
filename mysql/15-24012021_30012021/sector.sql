create table sector (
	id int not null auto_increment primary key,
	name varchar(150) not null,
    inserted_at timestamp not null default current_timestamp
);

create table channel_sector(
	channel_id int not null,
    sector_id int not null,
    primary key(channel_id, sector_id)
);
alter table channel_sector add constraint fk_channel_sector_channel foreign key(channel_id) references channel(id);
alter table channel_sector add constraint fk_channel_sectorsector foreign key(sector_id) references sector(id);

insert into sector(name) values('Painéis');
insert into sector(name) values('Alumínios');
insert into sector(name) values('Madeirados');
insert into sector(name) values('Acabamentos');

insert into channel_sector(channel_id, sector_id) values(14, 1);
insert into channel_sector(channel_id, sector_id) values(14, 2);
insert into channel_sector(channel_id, sector_id) values(14, 3);
insert into channel_sector(channel_id, sector_id) values(14, 4);

alter table machine_data add sector_id int null;
alter table machine_data add constraint fk_machine_data_sector foreign key(sector_id) references sector(id);

update machine_data set sector_id = 1 where code in('SQB10', 'LSQB01', 'SQBI12');
update machine_data set sector_id = 2 where code in('CABP031', 'CABP032');
update machine_data set sector_id = 3 where code in('CUN01', 'CUS17');
update machine_data set sector_id = 4 where code in('LB02', 'RB1', 'RB2', 'CABP1A', 'CABP1B', 'CABP2A', 'CABP2B');


