const router = require('express').Router();

module.exports = function(api) {
    const _machineWeekDayReportController = api.controllers.machineWeekDayReport;
    const _tokenController = api.controllers.token;

    router.get('/table', _tokenController.verify, _machineWeekDayReportController.table); 
    router.get('/chart', _tokenController.verify, _machineWeekDayReportController.chart);

    return router;
};