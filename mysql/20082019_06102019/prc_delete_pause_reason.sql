CREATE PROCEDURE `prc_delete_pause_reason`(in p_pause int)
BEGIN
	set @description = (select description from pause_reason where id = p_pause);
    
    set @msg = concat('Não é possível excluir a ração da pausa "', @description, '". Existem dados de pausas vinculados a ele.');
    
	if exists (select 1 from machine_pause where pause = p_pause) OR exists (select 1 from machine_pause_dash where pause_reason_id = p_pause) then 
		signal sqlstate '99999'
		set message_text = @msg;
    end if;
    
    delete from channel_pause_reason where pause_reason_id = p_pause;
	delete from pause_reason where id = p_pause;	
END