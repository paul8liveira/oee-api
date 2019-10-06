module.exports = function(api) {    
    let _action = api.models.action_improvement;

    this.post = function(req, res, next) {
        const body = req.body;

        //cria asserts para validação
        req.assert('channel_id', 'Preencha o id do canal corretamente.').notEmpty();
        req.assert('machine_code', 'Preencha o código da maquina corretamente.').notEmpty();
        req.assert('pause_reason_id', 'Preencha a pausa corretamente.').notEmpty();
        req.assert('description', 'Preencha a descrição corretamente.').notEmpty();
        req.assert('gain', 'Preencha o ganho corretamente.').notEmpty();
        req.assert('owner', 'Preencha o responsável corretamente.').notEmpty();
        req.assert('priority', 'Preencha a prioridade corretamente.').notEmpty();
        req.assert('status', 'Preencha o status corretamente.').notEmpty();
        req.assert('starts_at', 'Preencha a data de início corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);
        
        _action.save(body, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception);
            }
            const action = result[0][0] || {};
            return res.status(200).send(action || body);
        });
        
    };

    this.update = function(req, res, next) {
        const body = req.body;

        //cria asserts para validação
        req.assert('action_id', 'Preencha o id da ação corretamente.').notEmpty();
        req.assert('machine_code', 'Preencha o código da maquina corretamente.').notEmpty();
        req.assert('pause_reason_id', 'Preencha o id da pausa corretamente.').notEmpty();
        req.assert('description', 'Preencha a descrição corretamente.').notEmpty();
        req.assert('gain', 'Preencha o ganho corretamente.').notEmpty();
        req.assert('owner', 'Preencha o responsável corretamente.').notEmpty();
        req.assert('priority', 'Preencha a prioridade corretamente.').notEmpty();
        req.assert('status', 'Preencha o status corretamente.').notEmpty();
        req.assert('starts_at', 'Preencha a data de início corretamente.').notEmpty();
        
        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);                         
        
        _action.update(body, function(exception, results) {
            if(exception) {
                return res.status(500).send(exception);
            }    
            return res.send(body);           
        });            
                         
    };

    this.delete = function(req, res, next) {
        const body = req.body;

        //cria asserts para validação
        req.assert('action_id', 'Preencha o código corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);         
                        
        _action.delete(body, function(exception, results) {
            if(exception) {
                return res.status(400).send(exception);
            }
            return res.send(body);
        });            
                    
    };
    
    this.list = function(req, res, next) {
        const body = req.body;
        req.assert('action_id', 'Preencha o código da ação corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);

        _action.list(body, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.send(result);
        });                
    }; 

    this.listAll = function(req, res, next) {
        const channelId = req.params.channel;
        
        _action.listAll(channelId, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.send(result);
        });                
    }; 

    return this;
};