const router = require('express').Router();

module.exports = function(api) {
    const _improvementController = api.controllers.action_improvement;
    const _tokenController = api.controllers.token;

    router.post('/', _tokenController.verify, _improvementController.post);
    router.post('/update', _tokenController.verify, _improvementController.update);
    router.post('/delete', _tokenController.verify, _improvementController.delete);
    router.get('/:channel', _tokenController.verify, _improvementController.listAll);
    router.get('/', _tokenController.verify, _improvementController.list);

    return router;
};