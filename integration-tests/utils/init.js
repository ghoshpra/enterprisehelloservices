'use strict';

const AWS = require('aws-sdk');
AWS.config.region = 'us-west-2';


function init() {
    process.env.BASE_URL = 'https://nc035vbdie.execute-api.us-west-2.amazonaws.com/dev';
    
}

module.exports = init;