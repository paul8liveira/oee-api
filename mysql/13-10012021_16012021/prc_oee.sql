USE `oee`;
DROP procedure IF EXISTS `prc_oee`;

DELIMITER $$
USE `oee`$$
CREATE DEFINER=`root`@`%` PROCEDURE `prc_oee`(
	IN p_channel_id int,
	IN p_date_ini varchar(20),
	IN p_date_fin varchar(20),
	IN p_machine_code varchar(10)
)
begin
	create temporary table if not exists tmp_oee(
		channel_id int,
		machine_code varchar(10),
        machine_name varchar(100), 
		availability float(15,2),
		performance float(15,2),
		quality float(15,2),
		oee float(15,2)
	) engine=memory;

	create temporary table if not exists tmp_performance(
		machine_code varchar(10),
		field5 float(15,2),
		performance float(15,2)
	) engine=memory;
    
	create temporary table if not exists tmp_availability(
		machine_code varchar(10),
		pp float(15,2),
		pnp float(15,2)
	) engine=memory;
    
	/*para caso estiver na mesma sessão e tentar gerar oee novamente, as tmp nao serão dropadas*/
    delete from tmp_oee;
    delete from tmp_performance;
    delete from tmp_availability;

	/*disponibilidade*/
	insert into tmp_availability
	select b.machine_code
		 , sum(pp) as pp
		 , sum(pnp) as pnp
	  from (
	select a.machine_code 
		 , case a.type
			when 'PP' then sum(a.pause)
			else 0 end as pp
		 , case a.type
			when 'NP' then sum(a.pause)
			else 0 end as pnp        
	  from (       
		select mpd.machine_code
			 , pr.type
			 , mpd.pause 
		  from machine_pause_dash mpd
		  left join pause_reason pr on pr.id = mpd.pause_reason_id
		 where mpd.channel_id = p_channel_id 
           and ((mpd.machine_code = convert(p_machine_code using latin1) collate latin1_swedish_ci) or ifnull(p_machine_code, '') = '')
		   and mpd.date_ref between 
				   (STR_TO_DATE(p_date_ini, '%Y-%m-%d %H:%i:%s')) 
			   and (STR_TO_DATE(p_date_fin, '%Y-%m-%d %H:%i:%s'))
		 group by mpd.insert_index) a
	 group by a.machine_code, a.type) b
	 group by b.machine_code;

	/*desempenho */
	insert into tmp_performance 
	select coalesce(t.mc_cd, 'no data') as machine_code
		 , cast(coalesce(t.field5, 0) as decimal(15,2)) as field5
		 , case 
		     when t.category = 'linear' then
               round(coalesce((((t.field3 / (t.field5 - t.pause_pp - t.pause_np)) * t.nominal_output)), 0), 2)
		     when (t.field3 > 0 and t.manual_production = 0) then
				1
		     when (t.field3 = 0 and t.manual_production = 0) then
				0                
             else 
				round(((t.manual_production / (t.field5 - t.pause_pp))) / ((t.field5 - t.pause_pp - t.pause_np) / (t.field5 - t.pause_pp)), 2)
		  end as performance
	  from (
		select f.ch_id
			 , f.mc_cd
			 , sum(f.field5) as field5
			 , sum(f.field3) as field3 
             , m.nominal_output
             , m.category
             , coalesce(ta.pp, 0) as pause_pp
             , coalesce(ta.pnp, 0) as pause_np
             , case
			     when m.category = 'not_linear'
					then fnc_machine_production(f.ch_id, f.mc_cd, '', '', p_date_ini, p_date_fin) 
				 else 0 
			   end as manual_production
		  from feed f 
		 inner join (
			select max(f.id) as id
			  from feed f
			 where f.ch_id = p_channel_id
			   -- and f.field5 > 0 atenção: removido pq  influencia na performance, me avise se tiver interesse em mudar para avaliarmos juntos
			   and ((f.mc_cd = convert(p_machine_code using latin1) collate latin1_swedish_ci) or ifnull(p_machine_code, '') = '')
			   and f.inserted_at between 
				   (STR_TO_DATE(p_date_ini, '%Y-%m-%d %H:%i:%s'))  
			   and (STR_TO_DATE(p_date_fin, '%Y-%m-%d %H:%i:%s'))			
			 group by f.mc_cd
				 , date_format(f.inserted_at, '%d%m%Y')
		) tmp on f.id = tmp.id
		inner join machine_data m on m.code = f.mc_cd
         left join tmp_availability ta on ta.machine_code = f.mc_cd
        group by f.mc_cd
	) t; 

    set @v_quality = (select quality from channel where id = p_channel_id);
	
	insert into tmp_oee
	select p_channel_id
		 , t.machine_code
		 , m.name
		 , if(t.availability = 0, 0, round(((t.real_availability / t.availability) * 100), 2))
		 , round((t.performance * 100 ), 2)
		 , @v_quality
		 , if(t.availability = 0, 0, round(coalesce(((t.performance) * (t.real_availability / t.availability) * @v_quality), 0), 2))
	  from (
		select p.machine_code
			 , a.pp
			 , a.pnp
			 , p.performance
			 , (p.field5 - coalesce(a.pp, 0)) as availability
			 , ((p.field5 - coalesce(a.pp, 0)) - coalesce(a.pnp, 0)) as real_availability
		  from tmp_performance p
		  left join tmp_availability a on a.machine_code = p.machine_code
	) t
	 inner join machine_data m on m.code = t.machine_code;
    
    select * from tmp_oee;
end$$

DELIMITER ;