const { google } = require('googleapis');
const SCOPES = ['https://www.googleapis.com/auth/firebase.messaging'];

async function getAccessToken() {
    const key = require('./token_key.json');
    const jwtClient = new google.auth.JWT(
        key.client_email,
        null,
        key.private_key,
        SCOPES,
        null
    );
    const tokens = await jwtClient.authorize();
    return tokens.access_token;
}

async function run() {
    const token = await getAccessToken();
    console.log('Access Token:', token);
}

run();
