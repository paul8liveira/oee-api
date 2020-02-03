module.exports = function(api) {
    let _pool = api.database.connection; 
        
    this.list = function(params, callback) {
        var query = `
            select id
                , machine_code as machineCode
                , hour_ini as hourIni
                , hour_fin as hourFin
            from machine_shift
            where machine_code = ?
        `;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                params.machineCode
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };  

    this.add = function(data, callback) {
        _pool.getConnection(function(err, connection) {
            connection.query("call prc_machine_shift(?,?,?);", 
            [
                data.machineCode,
                data.hourIni,
                data.hourFin
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });    
    };

    this.delete = function(params, callback) {
        _pool.getConnection(function(err, connection) {
            connection.query("delete from machine_shift where id = ?", 
            [
                parseInt(params.id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });    
    };    

    this.OEE = function(params, callback) {
        _pool.getConnection(function(err, connection) {
            connection.query("call prc_shift_oee(?,?,?,?);", 
            [
                parseInt(params.channelId),
                params.machineCode,
                params.dateIni,
                params.dateFin
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });    
    };     

    this.machineWorkingHour = function(params, callback) {
        _pool.getConnection(function(err, connection) {
            const query = `
                select concat(t.hour_ini, t.hour_fin) as turn
                from (
                select (select replace(hour_ini, ':', '') as hour_ini
                        from machine_shift 
                        where machine_code = ? 
                        order by hour_ini 
                        limit 1) as hour_ini
                    , (select replace(hour_fin, ':', '') as hour_fin 
                        from machine_shift 
                        where machine_code = ?
                        order by hour_fin desc 
                        limit 1) as hour_fin
                ) t ;           
            `
            connection.query(query, 
            [
                params.machineCode,
                params.machineCode,
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });    
    };      

    return this;
};