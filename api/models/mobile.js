module.exports = function(api) {
    let _pool = api.database.connection; 

    this.chartGauge = function(data, callback) {
        let sql = `
            call prc_commands_executer(?,?,?,?,?);
            call prc_all_channel_oee(?,?);
        `;
        _pool.getConnection(function(err, connection) {
            connection.query(sql, [
                parseInt(data.channelId),
                data.machineCode,
                data.date, 
                data.date, 
                "mobile_gauge_chart",
                parseInt(data.channelId),
                data.dateFin,           
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };  

    return this;
};