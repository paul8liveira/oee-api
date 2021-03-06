const router = require('express').Router();

module.exports = function(api) {
    const _feedController = api.controllers.feed;
    const _tokenController = api.controllers.token;

    router.get('/update', _feedController.update); //n jwt
    router.get('/lastFeed', _tokenController.verify, _feedController.lastFeed);
    router.get('/chart', _tokenController.verify, _feedController.chart);
    router.get('/production', _tokenController.verify, _feedController.allProduction);
    router.get('/production/v2', _tokenController.verify, _feedController.allProductionV2);
    router.get('/oee', _tokenController.verify, _feedController.OEE);
    router.get('/all-channel-oee', _tokenController.verify, _feedController.allChannelOEE);
    //router.get('/:user/:channel/:machine/:date/:limit/feed/mobile', _feedController.mobile);

    return router;
};