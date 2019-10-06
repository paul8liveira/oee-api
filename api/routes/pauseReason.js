const router = require('express').Router();

module.exports = function(api) {
    const _pauseReasonController = api.controllers.pauseReason;
    const _tokenController = api.controllers.token;

    router.get('/dropdown/:channel', _tokenController.verify, _pauseReasonController.dropdown);    
    router.get('/listall/:channel', _tokenController.verify, _pauseReasonController.listall);
    router.get('/list/:id', _tokenController.verify, _pauseReasonController.list);
    router.post('/', _tokenController.verify, _pauseReasonController.post);    
    router.post('/update', _tokenController.verify, _pauseReasonController.update);
    router.post('/delete', _tokenController.verify, _pauseReasonController.delete);

    return router;
};