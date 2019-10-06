CREATE PROCEDURE `prc_progress`(	
	in p_channel_id int(11),
    in p_pause_reason_id int(11),
    in p_gain varchar(100),
	in p_description varchar(100),
    in p_action_description mediumtext,
	in p_owner varchar(45),
	in p_status int(1),
	in p_starts_at date,
    in p_finished_at date
)
BEGIN	
	if not exists (select 1 from channel_pause_reason where pause_reason_id = p_pause_reason_id and channel_id= p_channel_id) then 
		set @msg = 'Pausa selecionada não pertence ao canal';
        signal sqlstate '99999'
		set message_text = @msg;
    end if;
    
    insert into progress_improvement(channel_id, pause_reason_id, gain, description, action_description, owner, status, starts_at, finished_at)
    values(p_channel_id, p_pause_reason_id, p_gain, p_description, p_action_description, p_owner, p_status, p_starts_at, p_finished_at);
     
     select pi.id progress_id
            , pi.channel_id
            , pi.pause_reason_id
            , pi.gain 
            , pi.description
            , pi.action_description
            , pi.owner
            , pi.status
            , DATE_FORMAT(pi.starts_at, '%d/%m/%Y') starts_at
            , DATE_FORMAT(pi.finished_at, '%d/%m/%Y') finished_at
            , pi.created_at

            , c.name channel_name            
            , pr.name pause_name
            
        from progress_improvement pi
        inner join channel c on c.id = pi.channel_id
        inner join pause_reason pr on pr.id = pi.pause_reason_id
        where  pi.id = LAST_INSERT_ID();
END;
