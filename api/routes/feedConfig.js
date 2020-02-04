const router = require('express').Router();

module.exports = function(api) {
    const _feedConfigController = api.controllers.feedConfig;
    const _tokenController = api.controllers.token;
 
    router.get('/:channel', _tokenController.verify, _feedConfigController.list);    
    router.get('/:channel/logo', _tokenController.verify, _feedConfigController.logo);    
    router.post('/', _tokenController.verify, _feedConfigController.updateConfig);    
    router.post('/sql', _tokenController.verify, _feedConfigController.updateSQL);    

    return router;
};