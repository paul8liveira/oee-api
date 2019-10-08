module.exports = function(api) {
    let _machinePause = api.models.machinePause;
    const _alert = api.models.alert;
    const _mailer = api.services.mailer;
    
    this.hasAlert = function(req, res, next) {
        var query = req.query;

        const pauseFilter = {
            channel_id: 14, //por enquanto vou deixar fixo, só pra teste
            machine_code: query.mc,  
            date_ini: query.sd,
            date_fin: query.ed,
            pause_reason_id: query.pr,
            pause: query.p   
        };

        //verifica se tem alerta de pausa para enviar email
        _alert.hasAlertToSend(pauseFilter, async function(exception, alerts) {
            //se houve erro aqui, segue o processo e só faz um console
            if(exception) console.error(exception);
            
            //envia email (sem formatação e detalhes por enquanto)    
            if(alerts && alerts.length > 0) {
                const pauseReasonName = alerts[0].pause_reason_name;
                const mailsToAlert = alerts.map(m => m.sponsor_email).join(',');
                const html = `
                    A pausa <b>${pauseReasonName}</b> de <b>${pauseFilter.pause} minutos</b> foi lançada.
                    <br>Máquina: ${pauseFilter.machine_code}
                    <br>Data inicial da pausa: ${pauseFilter.date_ini}
                    <br>Data final da pausa: ${pauseFilter.date_fin}
                `;
                await _mailer.send(mailsToAlert, 'Alerta de pausa', html);
            }            
            next();
        });                                         
    };    

    this.save = function(req, res, next) {
        const query = req.query; 
                      
        _machinePause.save(query, function(exception, result) {
            if(exception) {
                return res.status(400).send(exception.sqlMessage);
            }
            const id = result[1][0] ? result[1][0].id.toString() : 0;
            res.status(200).send(id);                
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