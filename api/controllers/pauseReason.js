module.exports = function(api) {
    let _pauseReason = api.models.pauseReason;
    
    this.dropdown = function(req, res, next) {
        var channelId = req.params.channel;
        var machineCode = req.params.machine ? req.params.machine : '';
        
        _pauseReason.dropdown(channelId, machineCode, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.status(200).send(result);
        });                
    }; 

    return this;
};