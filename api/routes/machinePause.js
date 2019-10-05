const router = require('express').Router();

module.exports = function(api) {
    const _machinePauseController = api.controllers.machinePause;
    const _tokenController = api.controllers.token;

    router.get('/', _machinePauseController.hasAlert, _machinePauseController.save); //iot
    router.get('/list', _tokenController.verify, _machinePauseController.list);
    router.get('/pareto', _tokenController.verify, _machinePauseController.pareto);

    return router;
};