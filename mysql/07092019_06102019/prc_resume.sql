CREATE PROCEDURE `prc_resume`(
	in p_channel_id int(11),
	in p_overview mediumtext,
	in p_action mediumtext,    
	in p_owner varchar(45),
	in p_status int(1),
	in p_resume_date date
)
BEGIN
	insert into resume_improvement(channel_id, overview, action, owner, status, resume_date)
	values(p_channel_id, p_overview, p_action, p_owner, p_status, p_resume_date);
     
	select id resume_id
		, channel_id
		, overview
		, action
		, owner
		, status
		, resume_date
	from resume_improvement
	where id = LAST_INSERT_ID();
END;
