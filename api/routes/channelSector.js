const router = require('express').Router();

module.exports = function(api) {
    const _channelSectorController = api.controllers.channelSector;
    const _tokenController = api.controllers.token;
 
    router.get('/:channel_id', _tokenController.verify, _channelSectorController.list);    
    
    return router;
};