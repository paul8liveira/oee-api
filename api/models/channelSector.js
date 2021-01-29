module.exports = function (api) {
  let _pool = api.database.connection;

  this.list = function (channel_id, callback) {
    const query = `
        select s.id
            , s.name 
        from channel_sector cs
        join sector s on s.id = cs.sector_id
        where cs.channel_id = ?;
    `;
    _pool.getConnection(function (err, connection) {
      connection.query(query, [parseInt(channel_id)], function (error, result) {
        connection.release();
        callback(error, result);
      });
    });
  };

  return this;
};
