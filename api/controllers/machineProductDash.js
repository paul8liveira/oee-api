module.exports = function(api) {
    const _machineProductDash = api.models.machineProductDash;
        
    this.post = function (req, res, next) {
        const bodyData = req.body;

        const data = {
            channel_id: bodyData[0].channel_id,
            machine_code: bodyData[0].machine_code,            
            date_ini: bodyData[0].date_ref,
            date_fin: bodyData[1].date_ref,
            product_id: bodyData[0].product_id,
            amount: bodyData[1].amount   
        };

        _machineProductDash.save(data, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception);
            }     
            return res.status(200).send(result);           
        });  
    };

    return this;
};