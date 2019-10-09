module.exports = function(api) {
    let _pool = api.database.connection; 

    this.save = function(data, callback) {
        let query = 'call prc_action(?,?,?,?,?,?,?,?,?,?,?);';
        
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                data.channel_id,
                data.machine_code,
                data.pause_reason_id,
                data.description,
                data.gain,
                data.detailing,                
                data.owner,
                data.priority,
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
        let query = `update action_improvement set
                          machine_code = ?
                        , pause_reason_id = ?
                        , gain = ?
                        , description = ?
                        , detailing = ?
                        , owner = ?
                        , priority = ?
                        , status = ?
                        , starts_at = DATE_FORMAT(STR_TO_DATE(?, '%d/%m/%Y'), '%Y-%m-%d')
                        , finished_at = DATE_FORMAT(STR_TO_DATE(?, '%d/%m/%Y'), '%Y-%m-%d')
                      where id = ?`;
        
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                data.machine_code,
                parseInt(data.pause_reason_id),
                data.gain,
                data.description,
                data.detailing,
                data.owner,
                data.priority,
                data.status,
                data.starts_at,
                data.finished_at,
                parseInt(data.action_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };
    
    this.delete = function(data, callback) {    
        _pool.getConnection(function(err, connection) {
            connection.query("delete from action_improvement where id = ?;", 
            [
                parseInt(data.action_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });    
    };
    
    this.list = function(action_id, callback) {
        var query = `
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
            , DATE_FORMAT(starts_at, '%d/%m/%Y') starts_at
            , DATE_FORMAT(finished_at, '%d/%m/%Y') finished_at
            , ai.created_at
        from action_improvement ai
        inner join channel c on c.id = channel_id
        inner join machine_data m on m.code = machine_code
        inner join pause_reason pr on pr.id = pause_reason_id
        where  ai.id = ?`;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [ 
                parseInt(action_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };

    this.listAll = function(channelId, callback) {
        var query = `
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
            , DATE_FORMAT(starts_at, '%d/%m/%Y') starts_at
            , DATE_FORMAT(finished_at, '%d/%m/%Y') finished_at
            , ai.created_at
        from action_improvement ai
        inner join channel c on c.id = channel_id
        inner join machine_data m on m.code = machine_code
        inner join pause_reason pr on pr.id = pause_reason_id
        where channel_id = ?`;
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