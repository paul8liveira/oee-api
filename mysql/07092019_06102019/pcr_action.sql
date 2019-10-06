CREATE PROCEDURE `prc_action`(
p_channel_id int(11),
p_machine_code varchar(10),
p_pause_reason_id int(11),
p_gain varchar(20),
p_description varchar(100),
p_detailing mediumtext,                
p_owner varchar(45),
p_priority int(1),
p_status int(1),
p_finished_at date,
p_starts_at date)
BEGIN
	if not exists (select 1 from channel_pause_reason where pause_reason_id = p_pause_reason_id and channel_id= p_channel_id) then 
		set @msg = 'Pausa selecionada não pertence ao canal';
        signal sqlstate '99999'
		set message_text = @msg;
    end if;
    
	insert into action_improvement(channel_id, machine_code, pause_reason_id, gain, description, detailing, owner, priority, status, finished_at, starts_at)
    values(p_channel_id, p_machine_code,p_pause_reason_id, p_gain, p_description, p_detailing, p_owner, p_priority, p_status, p_finished_at, p_starts_at);
     
     select ai.id action_id
            , ai.channel_id
            , c.name channel_name
            , ai.machine_code
            , concat('[', m.code, '] ', m.name) as machine_label
            , ai.pause_reason_id
            , pr.name pause_name
            , ai.gain 
            , ai.description
            , ai.detailing
            , ai.owner
            , ai.priority
            , ai.status
            , DATE_FORMAT(ai.starts_at, '%d/%m/%Y') starts_at
            , DATE_FORMAT(ai.finished_at, '%d/%m/%Y') finished_at
            , ai.created_at
        from action_improvement ai
        inner join channel c on c.id = channel_id
        inner join machine_data m on m.code = machine_code
        inner join pause_reason pr on pr.id = pause_reason_id
        where ai.id = LAST_INSERT_ID();
END;
