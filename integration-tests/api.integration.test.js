'use strict';

const init = require('./utils/init');
const axios = require('axios');

describe('Invoking the hello API', () => {  
    beforeAll(() => {
        init();
      });

    test('Without a name parameter', async () => {
        const response = await axios.get(process.env.BASE_URL);
        expect(response.status).toBe(200);
        expect(response.data).toBe('Hello World');
    });

    
});


describe('Invoking the hello API', () => {  
    beforeAll(() => {
        init();
      });

    test('With a name parameter', async () => {
        const response = await axios.get(process.env.BASE_URL+ '?name=Pradipta');
        expect(response.status).toBe(200);
        expect(response.data).toBe('Hello Pradipta');
    });
});

