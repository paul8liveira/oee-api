const api = require('./autoload')();
const port = process.env.PORT || 3000;
const env = process.env.NODE_ENV || 'dev';

//routes
//ex local: /oee/api/
//ex google: /api/ ou /
const index_route = process.env.BASE_URL; 
const auth_route = process.env.BASE_URL + 'auth'; 
const machine_route = process.env.BASE_URL + 'machine';
const channel_route = process.env.BASE_URL + 'channel';
const feed_route = process.env.BASE_URL + 'feed';
const machinePause_route = process.env.BASE_URL + 'machinepause';
const pubsub_route = process.env.BASE_URL + 'pubsub';
const user_route = process.env.BASE_URL + 'user';
const userChannel_route = process.env.BASE_URL + 'userchannel';
const feedConfig_route = process.env.BASE_URL + 'channelconfig';
const machineConfig_route = process.env.BASE_URL + 'machineconfig';
const exportExcel_route = process.env.BASE_URL + 'exportexcel';
const yaman_route = process.env.BASE_URL + 'yaman';

//rotas que ouvimos
api.use(index_route, api.routes.index);
api.use(auth_route, api.routes.auth);
api.use(machine_route, api.routes.machine);
api.use(channel_route, api.routes.channel);
api.use(feed_route, api.routes.feed);
api.use(machinePause_route, api.routes.machinePause);
api.use(pubsub_route, api.routes.pubSub);
api.use(user_route, api.routes.user);
api.use(userChannel_route, api.routes.userChannel);
api.use(feedConfig_route, api.routes.feedConfig);
api.use(machineConfig_route, api.routes.machineConfig);
api.use(exportExcel_route, api.routes.exportExcel);
api.use(yaman_route, api.routes.yaman);

//rotas não encontradas serão respondidas por essa
api.use((req, res, next) => {
    const error = new Error('Not found');
    error.status = 404;
    next(error);
});

//faz o handle de qualquer erro lançado
api.use((error, req, res, next) => {
    res.status(error.status || 500);
    res.json({
        success: false,
        message: error.message
    });
});

api.listen(port, () => {
    console.log('listen on:', port, 'env:', env);   
});
