const router = require('express').Router();

module.exports = function(api) {
    const _improvementController = api.controllers.resume_improvement;
    const _tokenController = api.controllers.token;
    
    router.post('/', _tokenController.verify, _improvementController.post);
    router.post('/update', _tokenController.verify, _improvementController.update);
    router.post('/delete', _tokenController.verify, _improvementController.delete);
    router.get('/:channel_id', _tokenController.verify, _improvementController.listAll);
    router.get('/:channel_id/:resume_id', _tokenController.verify, _improvementController.list);
    
    return router;
};