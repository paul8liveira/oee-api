module.exports = function(api) {
    let _pool = api.database.connection; 
    
    this.dropdown = function(channelId, callback) {
        var query = `
            select pr.id
                 , pr.name
              from channel_pause_reason cpr
             inner join pause_reason pr on pr.id = cpr.pause_reason_id
             where cpr.channel_id = ?
               and pr.active = 1
             order by pr.name
        `;
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

    this.list = function(id, callback) {
        var query = `
            select pr.id pause_reason_id
                 , pr.name
                 , pr.description
                 , case pr.active when 1 then 1 else 0 end as active
                 , pr.type
                 , pr.created_at
              from pause_reason pr where pr.id = ?
        `;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                parseInt(id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };

    this.listall = function(channelId, callback) {
        var query = `
            select pr.id pause_reason_id
                 , pr.name
                 , pr.description
                 , case pr.active when 1 then 1 else 0 end as active
                 , pr.type
                 , pr.created_at
            from channel_pause_reason cpr
             inner join pause_reason pr on pr.id = cpr.pause_reason_id
             where cpr.channel_id = ?
             order by pr.name
        `;
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

    this.save = function(data, callback) {
        let sql = `call pcr_pause_reason (?, ?, ?, ?, ?);`;
        
        _pool.getConnection(function(err, connection) {
            connection.query(sql, 
            [   
                parseInt(data.channel_id),
                data.name,
                data.description,
                data.type,
                parseInt(data.active)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result[0][0]);
            });
        });
    };

    this.update = function(data, callback) {
        let sql = `UPDATE pause_reason SET
                    name=?,
                    description=?,
                    type=?,
                    active=?
                WHERE id=?`;
        
        _pool.getConnection(function(err, connection) {
            connection.query(sql, 
            [   
                data.name,
                data.description,
                data.type,
                parseInt(data.active),
                parseInt(data.pause_reason_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };

    this.delete = function(data, callback) {
        let sql = `CALL prc_delete_pause_reason(?)`;
        
        _pool.getConnection(function(err, connection) {
            connection.query(sql, 
            [   
                parseInt(data.pause_reason_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };

    return this;
};