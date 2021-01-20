alter table machine_data add column category varchar(30);

update machine_data set category = 'not_linear' where code = 'CABP031';
update machine_data set category = 'not_linear' where code = 'CABP032';
update machine_data set category = 'not_linear' where code = 'CABP1A';
update machine_data set category = 'not_linear' where code = 'CABP1B';
update machine_data set category = 'not_linear' where code = 'CABP2A';
update machine_data set category = 'not_linear' where code = 'CABP2B';
update machine_data set category = 'not_linear' where code = 'CUN01';
update machine_data set category = 'not_linear' where code = 'CUS17';
update machine_data set category = 'not_linear' where code = 'RB1';
update machine_data set category = 'not_linear' where code = 'RB2';
update machine_data set category = 'linear' where code = 'LB02';
update machine_data set category = 'linear' where code = 'LSQB01';
update machine_data set category = 'linear' where code = 'SQB10';
update machine_data set category = 'linear' where code = 'SQBI12';