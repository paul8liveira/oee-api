const router = require('express').Router();

module.exports = function(api) {
    const _systemController = api.controllers.system;
    
    router.get('/hour', _systemController.hour); //n jwt
    
    return router;
};