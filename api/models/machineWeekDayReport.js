module.exports = function(api) {
    const _pool = api.database.connection; 
    
    this.table = function({ channelId, machineCode, yearNumber, weekNumber, dateIni, dateEnd }, callback) {
        _pool.getConnection(function(err, connection) {
            connection.query("call prc_machine_week_day_report(?, ?, ?, ?, ?, ?)", 
            [
                parseInt(channelId),
                machineCode,
                yearNumber || '',
                weekNumber || '',
                dateIni || '',
                dateEnd || ''
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });     
    };    

    this.chart = function({ channelId, machineCode, yearNumber, weekNumber, dateIni, dateEnd }, callback) {
        _pool.getConnection(function(err, connection) {            
            connection.query("call prc_machine_week_day_report_chart(?, ?, ?, ?, ?, ?)", 
            [
                parseInt(channelId),
                machineCode,
                yearNumber || '',
                weekNumber || '',
                dateIni || '',
                dateEnd || ''
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });     
    };        

    return this;
};