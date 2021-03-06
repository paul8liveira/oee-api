module.exports = function(api) {
    let _pool = api.database.connection; 

    this.list = function(machineCode, callback) {
        var query = `
            select * 
              from machine_config
             where machine_code = ?
        `;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                machineCode
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };      

    this.updateSQL = function(data, callback) {        
        let query = `
            update machine_config 
               set chart_sql = ?
                 , mobile_sql = ?
                 , chart_tooltip_desc = ?
                 , max_day_production = ?
             where machine_code = ?
        `;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                data.chart_sql, 
                data.mobile_sql,
                data.chart_tooltip_desc,                
                parseFloat(data.max_day_production),
                data.machine_code
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };    

    return this;
};