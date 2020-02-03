module.exports = function(api) {
    let _pool = api.database.connection; 
        
    this.dropdown = function(channelId, machineCode, callback) {
        var query = `
            select pr.id
                 , pr.name
              from channel_pause_reason cpr
             inner join pause_reason pr on pr.id = cpr.pause_reason_id
             where cpr.channel_id = ?
               and pr.active = 1
               and ((cpr.machine_code = ?) or (? = ''))
             order by pr.name
        `;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                parseInt(channelId),
                machineCode,
                machineCode
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };  

    return this;
};