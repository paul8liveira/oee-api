module.exports = function(api) {    
    let _progress = api.models.progress_improvement;

    this.post = function(req, res, next) {
        const body = req.body;

        //cria asserts para validação        
        req.assert('channel_id', 'Preencha o id do canal corretamente.').notEmpty();
        req.assert('pause_reason_id', 'Preencha o id da pausa corretamente.').notEmpty();
        req.assert('description', 'Preencha a descrição corretamente.').notEmpty();
        req.assert('action_description', 'Preencha a descrição da ação corretamente.').notEmpty();
        req.assert('owner', 'Preencha o responsável corretamente.').notEmpty();
        req.assert('gain', 'Preencha a descrição do ganho corretamente.').notEmpty();
        req.assert('status', 'Preencha o status corretamente.').notEmpty();
        req.assert('starts_at', 'Preencha a data de inicio corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);
        
        _progress.save(body, function(exception, result) {
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
        req.assert('progress_id', 'Preencha o id do progresso da ação corretamente.').notEmpty();        
        req.assert('channel_id', 'Preencha o id do canal corretamente.').notEmpty();
        req.assert('pause_reason_id', 'Preencha o id da pausa corretamente.').notEmpty();
        req.assert('description', 'Preencha a descrição corretamente.').notEmpty();
        req.assert('action_description', 'Preencha a descrição da ação corretamente.').notEmpty();
        req.assert('owner', 'Preencha o responsável corretamente.').notEmpty();
        req.assert('gain', 'Preencha a descrição do ganho corretamente.').notEmpty();
        req.assert('status', 'Preencha o status corretamente.').notEmpty();
        req.assert('starts_at', 'Preencha a data de inicio corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);                         
        
        _progress.update(body, function(exception, results) {
            if(exception) {
                return res.status(500).send(exception);
            }    
            return res.send(body);           
        });            
                         
    };

    this.delete = function(req, res, next) {
        const body = req.body;

        //cria asserts para validação
        req.assert('progress_id', 'Preencha o código corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);         
                        
        _progress.delete(body, function(exception, results) {
            if(exception) {
                return res.status(400).send(exception);
            }
            return res.send(body);
        });            
                    
    };
    
    this.listProgress = function(req, res, next) {
        const {progress_id} = req.params;
        
        if ( progress_id == undefined ){
            return res.status(400).json({
                "success": false,
                "message": "Informe o id da progresso"
            });
        }

        _progress.list(progress_id, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.send(result);
        });        
    };

    this.listChannel = function(req, res, next) {
        const {channel_id} = req.params;
        
        if ( channel_id == undefined ){
            return res.status(400).json({
                "success": false,
                "message": "Informe o id  canal"
            });
        }

        _progress.listByChannel(channel_id, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.send(result);
        }); 
        
    };
    return this;
};