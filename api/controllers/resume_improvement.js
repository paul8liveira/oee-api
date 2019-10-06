module.exports = function(api) {    
    let _resume = api.models.resume_improvement;

    this.post = function(req, res, next) {
        const body = req.body;

        //cria asserts para validação        
        req.assert('channel_id', 'Preencha o id do canal corretamente.').notEmpty();
        req.assert('overview', 'Preencha a anásile corretamente.').notEmpty();        
        req.assert('owner', 'Preencha o responsável corretamente.').notEmpty();        
        req.assert('status', 'Preencha o status corretamente.').notEmpty();
        req.assert('action', 'Preencha a ação corretamente.').notEmpty();        
        req.assert('resume_date', 'Preencha a data corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);
        
        _resume.save(body, function(exception, result) {
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
        req.assert('resume_id', 'Preencha o id do resume da ação corretamente.').notEmpty();        
        req.assert('overview', 'Preencha a anásile corretamente.').notEmpty();        
        req.assert('owner', 'Preencha o responsável corretamente.').notEmpty();        
        req.assert('status', 'Preencha o status corretamente.').notEmpty();
        req.assert('action', 'Preencha a ação corretamente.').notEmpty();        
        req.assert('resume_date', 'Preencha a data corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);                         
        
        _resume.update(body, function(exception, results) {
            if(exception) {
                return res.status(500).send(exception);
            }    
            return res.send(body);           
        });            
                         
    };

    this.delete = function(req, res, next) {
        const body = req.body;

        //cria asserts para validação
        req.assert('resume_id', 'Preencha o código corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);         
                        
        _resume.delete(body, function(exception, results) {
            if(exception) {
                return res.status(400).send(exception);
            }
            return res.send(body);
        });            
                    
    };
    
    this.listAll = function(req, res, next) {        
        const { channel_id } = req.params;
        
        if ( channel_id == undefined ){
            return res.status(400).json({
                "success": false,
                "message": "Informe o id do channel"
            });
        }

        _resume.listAll(channel_id, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.send(result);
        });                
    };

    this.list = function(req, res, next) {        
        const { resume_id } = req.params;
        
        if ( resume_id == undefined ){
            return res.status(400).json({
                "success": false,
                "message": "Informe o id do resumo"
            });
        }

        _resume.list(resume_id, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.send(result);
        });                
        
    };

    return this;
};