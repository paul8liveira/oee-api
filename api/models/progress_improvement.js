module.exports = function(api) {
    let _pool = api.database.connection; 

    this.save = function(data, callback) {
        let query = 'call prc_progress(?,?,?,?,?,?,?,?,?);';
        
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [                
                data.channel_id,
                data.pause_reason_id,
                data.gain,
                data.description,
                data.action_description,
                data.owner,
                data.status,
                data.starts_at,
                data.finished_at
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };
    
    this.update = function(data, callback) {
        let query = `update progress_improvement 
                        set pause_reason_id = ?
                        , gain = ?
                        , description = ?
                        , action_description = ?
                        , owner = ?
                        , status = ?
                        , starts_at = DATE_FORMAT(STR_TO_DATE(?, '%d/%m/%Y'), '%Y-%m-%d')
                        , finished_at = DATE_FORMAT(STR_TO_DATE(?, '%d/%m/%Y'), '%Y-%m-%d')
                      where id = ?`;
        
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                data.pause_reason_id,
                data.gain,
                data.description,
                data.action_description,
                data.owner,
                data.status,
                data.starts_at,
                data.finished_at,
                parseInt(data.progress_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };
    
    this.delete = function(data, callback) {    
        _pool.getConnection(function(err, connection) {
            connection.query("delete from progress_improvement where id = ?;", 
            [
                parseInt(data.progress_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });    
    };
    
    this.list = function(progress_id, callback) {
        var query = `
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
            where  pi.id = ?`;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [ 
                parseInt(progress_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };    


    this.listByChannel = function(channelId, callback) {
        var query = `
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
            where pi.channel_id = ?`;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [ 
                parseInt(channelId)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };

    return this;
};