alter table feed drop index feed_inserted_at_index;

alter table feed add index idx_feed_ch_id_mc_cd_inserted_at(ch_id, mc_cd, inserted_at);