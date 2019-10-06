const router = require('express').Router();

module.exports = function(api) {
    const _improvementController = api.controllers.progress_improvement;
    const _tokenController = api.controllers.token;

    router.post('/', _tokenController.verify, _improvementController.post);
    router.post('/update', _tokenController.verify, _improvementController.update);
    router.post('/delete', _tokenController.verify, _improvementController.delete);
    router.get('/:progress_id', _tokenController.verify, _improvementController.listProgress);
    router.get('/channel/:channel_id', _tokenController.verify, _improvementController.listChannel);
    
    return router;
};