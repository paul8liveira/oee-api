const express = require('express');
const bodyParser = require('body-parser');
const consign = require('consign');
const expressValidator = require('express-validator');
const config  = require('./config-app'); 
const env = process.env.NODE_ENV || 'dev';

module.exports = function() {
    var app = express(); 
    app.set('jwtSecret', config.jwtSecret);
    app.use(expressValidator());

    app.use(bodyParser.urlencoded({
        extended: true
    }));    
    app.use(bodyParser.json());

    //somente para teste
    if(env == 'dev') {
        app.use(function(req, res, next) {
            res.header("Access-Control-Allow-Origin", "http://localhost:4200");
            res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
            next();
        });        
    } 

    consign()
        .include('controllers')
        .then('database')
        .into(app);

    return app;
}