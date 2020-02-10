module.exports = function(api) {
    this.hour = function(req, res, next) {
        const moment = require('moment');
        const hour = moment().utcOffset("-03:00").format('HHmmss');
        return res.status(200).send(hour);
    }; 

    return this;
};