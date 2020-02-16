const router = require('express').Router();

module.exports = function(api) {
    const _productController = api.controllers.product;
    const _tokenController = api.controllers.token;

    router.post('/', _tokenController.verify, _productController.post);
    router.post('/update', _tokenController.verify, _productController.update);
    router.post('/delete', _tokenController.verify, _productController.delete);    
    router.get('/:channel_id', _tokenController.verify, _productController.list);    
    
    return router;
};