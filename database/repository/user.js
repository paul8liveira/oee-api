const bcrypt = require('bcrypt-nodejs');
const saltRounds = 10;

function user(pool) {
    this.pool = pool;
}

user.prototype.autentication = function(username, callback) {
    let query = `
        select case u.admin when 1 then 1 else 0 end as admin
             , u.username
             , u.password 
             , u.id             
             , c.name
             , c.initial_turn
             , c.final_turn
          from user u
          left join user_channel uc on uc.user_id = u.id
          left join channel c on c.id = uc.channel_id
         where u.username = ?
           and u.active = true
         order by c.id
         limit 1
    `;

    this.pool.getConnection(function(err, connection) {
        connection.query(query, username, function(error, result) {
            connection.release();
            callback(error, result);
        });
    });    
}

user.prototype.list = function(callback) {
    var query = `
        select u.id
            , u.username
            , u.password
            , case u.active when 1 then 'Ativo' else 'Inativo' end as active
            , case u.admin when 1 then 'Sim' else 'Não' end as admin
            , DATE_FORMAT(u.created_at, '%d/%m/%Y %H:%i:%s') as created_at
            , company_name
            , phone
         from user u	
    `; 
    
    this.pool.getConnection(function(err, connection) {
        connection.query(query, [], function(error, result) {
            connection.release();
            callback(error, result);
        });
    });
}

user.prototype.save = function(data, callback) {
    let salt = bcrypt.genSaltSync(saltRounds);
    if(data.isMobile) {
        this.pool.getConnection(function(err, connection) {
            connection.query("call prc_user_mobile(?,?,?,?,?,?)", 
            [
                data.company_name,
                data.username,
                bcrypt.hashSync(data.password, salt),
                data.active,
                data.admin,
                data.phone
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    }
    else {
        this.pool.getConnection(function(err, connection) {
            connection.query("set @userId = 0; call prc_user(?,?,?,?,?,?,@userId)", 
            [
                data.username,
                bcrypt.hashSync(data.password, salt),
                data.active,
                data.admin,
                data.company_name,
                data.phone
            ], 
            function(error, result) {
                connection.release();
                callback(error, result);
            });
        });
    }
}

user.prototype.update = function(data, callback) {
    let datetime = new Date();
    let query = `
        update user set active = ?
                      , admin = ? 	
                      , company_name = ?
                      , phone = ?
				  where id = ?
    `;
    
    this.pool.getConnection(function(err, connection) {
        connection.query(query, 
        [
            data.active, 
            data.admin, 
            data.company_name,
            data.phone,
            data.id
        ], 
        function(error, result) {
            connection.release();
            callback(error, result);
        });
    });
}

user.prototype.delete = function(data, callback) {
    this.pool.getConnection(function(err, connection) {
        connection.query("call prc_delete_user(?)", [data.id], 
        function(error, result) {
            connection.release();
            callback(error, result);
        });
    });    
}

module.exports = function() {
    return user;
};