module.exports = function(api) {
    const _product = api.models.product;

    this.post = function(req, res, next) {
        const { body } = req;

        //cria asserts para validação
        req.assert('channel_id', 'Preencha o canal corretamente.').notEmpty();
        req.assert('machine_code', 'Preencha a máquina corretamente.').notEmpty();
        req.assert('name', 'Preencha o nome corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);

        _product.save(body, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception);
            }
            const [el] = result;
            return res.status(200).send(el[0]);
        });          
                          
    }; 

    this.update = function(req, res, next) {
        const { body } = req;

        //cria asserts para validação
        req.assert('channel_id', 'Preencha o canal corretamente.').notEmpty();
        req.assert('machine_code', 'Preencha a máquina corretamente.').notEmpty();
        req.assert('name', 'Preencha o nome corretamente.').notEmpty();
        req.assert('id', 'Preencha o id corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);                   
        
        _product.update(body, function(exception, results, fields) {
            if(exception) {
                return res.status(400).send(exception);
            }    
            return res.send(results);           
        });            
                         
    };

    this.delete = function(req, res, next) {
        const { body } = req;

        //cria asserts para validação
        req.assert('id', 'Preencha o código corretamente.').notEmpty();

        var errors = req.validationErrors();
        if(errors)
            return res.status(400).send(errors);         
                        
        _product.delete(body, function(exception, results, fields) {
            if(exception) {
                return res.status(400).send(exception);
            }
            return res.send(results);
        });            
                    
    };
    
    this.list = function(req, res, next) {
        const { channel_id } = req.params;
        
        _product.list(channel_id, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.send(result);
        });                
    }; 
    
    return this;
};