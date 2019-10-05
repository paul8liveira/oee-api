module.exports = function(api) {
    let _machinePause = api.models.machinePause;

    this.save = function(req, res, next) {
        var query = req.query;  
                      
        _machinePause.save(query, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception.sqlMessage);
            }
            res.status(200).send(result.affectedRows === 1);                
        });                 
    }; 

    this.list = function(req, res, next) {
        var query = req.query;       
        
        _machinePause.listPauses(query, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception);
            }
            let dataResult = {
                pauses: result[0],
                pause_grouped: result[1][0] || []
            }
            res.status(200).send(dataResult);            
        });                  
    };

    this.pareto = function(req, res, next) {
        var query = req.query;       
        
        _machinePause.pareto(query, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception);
            }
            let dataResult = {
                pareto: result[0] || []
            }
            res.status(200).send(dataResult);            
        });                  
    };    
    
    return this;
};