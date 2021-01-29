module.exports = function(api) {
    const _channelSector = api.models.channelSector;
    
    this.list = function(req, res, next) {
        const { channel_id } = req.params;
        
        _channelSector.list(channel_id, function(exception, result) {
            if(exception) {
                return res.status(500).send(exception);
            }
            res.send(result);
        });                
    }; 
    
    return this;
};