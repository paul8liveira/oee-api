module.exports = function(api) {
    let _pool = api.database.connection; 

    this.save = function(data, callback) {
        const query = 'call prc_product(?, ?, ?, ?, ?, ?);';
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                parseInt(0),
                parseInt(data.channel_id),
                data.machine_code,
                data.name,
                parseFloat(data.cycle_time),
                data.measure_unit
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };
    
    this.update = function(data, callback) {
        const query = 'call prc_product(?, ?, ?, ?, ?, ?);';
        
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                parseInt(data.id),
                parseInt(data.channel_id),
                data.machine_code,
                data.name,
                parseFloat(data.cycle_time),
                data.measure_unit
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };
    
    this.delete = function(data, callback) {    
        _pool.getConnection(function(err, connection) {
            connection.query("delete from product where id = ?", 
            [
                parseInt(data.id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });    
    };
    
    this.list = function(channel_id, machine_code, callback) {
        const query = `
            select p.*
                , c.name as channel_name
                , m.name as machine_name
            from product p
            inner join channel c on c.id = p.channel_id
            inner join machine_data m on m.code = p.machine_code
            where p.channel_id = ?
              and ((p.machine_code = ?) or ? = ''); 
        `;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                parseInt(channel_id),
                machine_code,
                machine_code ? machine_code : ''
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };

    return this;
};