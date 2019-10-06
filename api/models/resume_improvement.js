module.exports = function(api) {
    let _pool = api.database.connection; 

    this.save = function(data, callback) {
        let query = 'call prc_resume(?,?,?,?,?,?);';
        
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                data.channel_id,
                data.overview,
                data.action,
                data.owner,
                data.status,
                data.resume_date
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };
    
    this.update = function(data, callback) {
        let query = `update resume_improvement 
                        set overview = ?
                        , action = ?
                        , owner = ?
                        , status = ?
                        , resume_date = ?
                      where id = ?`;
        
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [
                data.overview,
                data.action,
                data.owner,
                data.status,
                data.resume_date,
                parseInt(data.resume_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };
    
    this.delete = function(data, callback) {    
        _pool.getConnection(function(err, connection) {
            connection.query("delete from resume_improvement where id = ?;", 
            [
                parseInt(data.resume_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });    
    };
    
    this.list = function(resume_id, callback) {
        var query = `
            select id resume_id
            , channel_id
            , overview
            , action
            , owner
            , status
            , resume_date
            , MONTH(resume_date) month
        from resume_improvement
        where id = ?`;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [ 
                parseInt(resume_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };    

    
    this.listAll = function(channel_id, callback) {
        var query = `
        select ri.id resume_id
            , ri.channel_id
            , c.name channel_name
            , ri.overview
            , ri.action
            , ri.owner
            , ri.status
            , ri.resume_date
            , MONTH(resume_date) month
        from resume_improvement ri
        inner join channel c on c.id = ri.channel_id
        where ri.channel_id = ?`;
        _pool.getConnection(function(err, connection) {
            connection.query(query, 
            [ 
                parseInt(channel_id)
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    };

    return this;
};