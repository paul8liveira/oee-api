module.exports = function(api) {
    let _pool = api.database.connection; 
    
    this.save = function(data, callback) {
        _pool.getConnection(function(err, connection) {
            connection.query("call prc_machine_product_dash(?,?,?,?,?,?,?)", 
            [
                parseInt(data.channel_id),
                data.machine_code,
                data.date_ini,
                data.date_fin,
                parseInt(data.product_id),
                parseFloat(data.amount),
                parseInt(data.time_in_min)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });     
    };

    this.pareto = function(data, callback) {
        var query = `
            call prc_chart_product_pareto(?, ?, ?);          
        `; 
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                parseInt(data.channel_id),
                data.machine_code,
                parseInt(data.filter)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };    

    return this;
};