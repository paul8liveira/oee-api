const router = require('express').Router();

module.exports = function(api) {
    const _machineProductDashController = api.controllers.machineProductDash;
    const _tokenController = api.controllers.token;

    router.post('/', _tokenController.verify, _machineProductDashController.post); 
    router.get('/pareto', _tokenController.verify, _machineProductDashController.pareto);

    return router;
};