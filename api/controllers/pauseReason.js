module.exports = function(api) {
    let _pauseReason = api.models.pauseReason;
    
    this.dropdown = function(req, res, next) {
        var channelId = req.params.channel;
        
        _pauseReason.dropdown(channelId, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.status(200).send(result);
        });                
    }; 

    this.list = function(req, res, next) {
        var id = req.params.id;
        
        _pauseReason.list(id, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.status(200).send(result);
        });                
    }; 

    this.listall = function(req, res, next) {
        var channelId = req.params.channel;
        
        _pauseReason.listall(channelId, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.status(200).send(result);
        });                
    }; 

    this.post = function(req, res, next) {
        var bodyData = req.body;

        //cria asserts para validação
        req.assert('channel_id', 'Preencha o channel corretamente.').notEmpty();
        req.assert('name', 'Preencha o nome corretamente.').notEmpty();
        //req.assert('description', 'Preencha a descrição corretamente.').notEmpty();        
        req.assert('type', 'Preencha o tipo corretamente.').notEmpty();
        req.assert('active', 'Preencha o active corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);                    
        
        _pauseReason.save(bodyData, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception);
            }
            
            return res.status(200).send(result);
        });         
    }; 

    this.update = function(req, res, next) {
        var bodyData = req.body;

        //cria asserts para validação            
        req.assert('pause_reason_id', 'Preencha o id da pause corretamente.').notEmpty();
        req.assert('name', 'Preencha o name corretamente.').notEmpty();
        //req.assert('description', 'Preencha a description corretamente.').notEmpty();        
        req.assert('type', 'Preencha o typr corretamente.').notEmpty();
        req.assert('active', 'Preencha o active corretamente.').notEmpty();
        
        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);                    
        
        _pauseReason.update(bodyData, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception);
            }
            
            return res.status(200).send(result);
        });   
    };

    this.delete = function(req, res, next) {
        var bodyData = req.body;

        //cria asserts para validação            
        req.assert('pause_reason_id', 'Preencha o id da pause corretamente.').notEmpty();
        
        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);                    
        
        _pauseReason.delete(bodyData, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception);
            }
            
            return res.status(200).send(result);
        });   
    };

    return this;
};