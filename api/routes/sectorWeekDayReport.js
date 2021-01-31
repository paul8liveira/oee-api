const router = require('express').Router();

module.exports = function(api) {
    const _sectorWeekDayReportController = api.controllers.sectorWeekDayReport;
    const _tokenController = api.controllers.token;

    router.get('/table', _tokenController.verify, _sectorWeekDayReportController.table); 
    router.get('/chart', _tokenController.verify, _sectorWeekDayReportController.chart);

    return router;
};