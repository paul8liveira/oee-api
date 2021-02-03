module.exports = function(api) {
    const _pool = api.database.connection; 
    
    this.table = function({ channelId, sectorId, yearNumber, weekNumber, date }, callback) {
        _pool.getConnection(function(err, connection) {
            connection.query("call prc_sector_week_day_report(?, ?, ?, ?, ?)", 
            [
                parseInt(channelId),
                parseInt(sectorId),
                yearNumber || '',
                weekNumber || '',
                date || '',
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });     
    };    

    this.chart = function({ channelId, sectorId, yearNumber, weekNumber, dateIni, dateEnd }, callback) {
        _pool.getConnection(function(err, connection) {            
            connection.query("call prc_sector_week_day_report_chart(?, ?, ?, ?, ?, ?)", 
            [
                parseInt(channelId),
                parseInt(sectorId),
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