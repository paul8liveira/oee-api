CREATE PROCEDURE `pcr_pause_reason`(
	in p_channel_id int(11),
	in p_name varchar(100),
    in p_description varchar(500),
    in p_type char(2),
    in p_active bit
)
BEGIN
	DECLARE pause_reason_id int(11);
	
    INSERT INTO pause_reason (name, description, active, created_at, type)
				VALUES(p_name, p_description, p_active, now(), p_type);    
    
    SET pause_reason_id = LAST_INSERT_ID();
    
    INSERT INTO channel_pause_reason (channel_id, pause_reason_id, created_at)
					VALUES(p_channel_id, pause_reason_id, now());
	
	 SELECT id pause_reason_id
		 , name
		 , description
		 , CASE active WHEN 1 THEN 1 ELSE 0 END AS active
		 , type
	FROM pause_reason WHERE id=pause_reason_id;
END