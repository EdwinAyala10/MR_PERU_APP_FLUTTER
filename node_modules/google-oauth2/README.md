node-google-oauth2
==================

Google OAuth2 authentication tools for GoogleDrive, GMail and many other Google APIs.
With borrowed code from [node-gAUth by Ben Lyaunzon](https://github.com/lyaunzbe/node-gAuth).

For some reason Google decided to document their new APIs on an SDK level only, e.g. they do not provide documentation for the REST APIs.
Instead they talk about how to use their client libraries for "popular" platforms. Server-side JS is not among them. This sucks.

Earlier versions of Google APIs were documented on a REST level. They are deprecated and, at least in one instance, [Google broke an API](http://stackoverflow.com/questions/13552687/google-document-list-api-v2-regression-feed-does-not-contain-all-documents) and [does not even acknowledge the fact](http://code.google.com/a/google.com/p/apps-api-issues/issues/detail?id=3274).
This sucks even more.

end of rant.

Preparation
----------

First you need to register your application or service with [Google's API console](https://code.google.com/apis/console) aka Dashboard
- go to *Services* and enable the API you want to use
- go to *API Access* and create a Client ID
- copy the strings labeled *Client-ID* and *Client-Secret*
- paste them into a file called oauth2-config.js and put it into your project (but don't check it in!)

oauth2-config.js should look something like this:

    module.exports = {
        // these are from the Google API console web interface
        // https://code.google.com/apis/console
        // (Section CLient ID for installed Application)
        client_id: "xxxxxxxxxxxx.apps.googleusercontent.com",
        client_secret: "xxxxxxxx_xxxxxxxxxxxxxxx",    
    };


Auth Code
---------

Before your app can use a user's data, it must be authorized by the user for a certain set of permissions (a "scope").
More about scopes [here](https://developers.google.com/drive/training/drive-apps/auth/scopes).

With the client id, client secret and the scope, you can now request an auth code for a particular google account.

    config = require("oauth2-config.js")
    goauth2 = require("google-oauth2")(config)
    scope = "https://www.googleapis.com/auth/userinfo.profile"
    
    goauth2.getAuthCode scope, (err, auth_code) ->
        console.log auth_code

Normally this would happen in a web session. Because the user needs a way to grant permissions, the code above will open a
local web browser. Here you can log into your account and grant the permissions defined by the scope.
The Google Auth server will then redirect to localhost:3000 where a temporary http server (created inside *getAuthCode*) will
receive the auth code.

Because opening a web browser in a headless server environment often is not an option, we should think about a different solution. See [Authorization Automation](#authorization-automation) below.

Tokens
------

With the auth code, you can now request tokens.
      
    goauth2.getTokensForAuthCode auth_code, (err, result) ->
        console.log result.access_token
        console.log result.refresh_token

The access token is needed to make actual API calls. However, it will expire after a while.
(typically one hour). The refresh token on the other hand can be used to get a fresh access token for another
hour of API fun.

    goauth2.getAccessTokenForRefreshToken refresh_token, (err, result) ->
        console.log result.access_token

Make API calls
--------------

Here's an example of how you would use an access token in an HTTP Authorization header:

    curl -H "Authorization: Bearer {access_token}" \
    -H "Content-Type: application/json" \
    https://www.googleapis.com/drive/v2/files

NOTE: This will only succeed if you requested the google drive metadata scope

Authorization Automation
------------------------

As said before, in a headless server environment it is not really an opten to open a web browser to grant access permissions.
If your service want to access its own google account rather than arbitrary user accounts, for example to store and share google drive documents with your users, there might be another option.

In that case you could put a google account name and password in oauth2-config.js and automate the following steps:
- open a headless phantomJS browser session that is instrumented with a script
- navigate to the google account login page
- autofill account name and password and login
- navigate to the grant permission page and automatically click the blue button

This would not only improve this module's unit tests, it would also be a solution for server-side
authorization of the service's own google account. And this process could be integrated with automatic provisioning. (Infrastructure is Code)

What can I say? It nearly works! [This phantomjs script](https://github.com/regular/node-google-oauth2/blob/master/lib/google-login-phantomjs-script.coffee) tries to performs the steps above. All you need to do to see it fail is uncomment the first test in [test/test.coffee](https://github.com/regular/node-google-oauth2/blob/master/test/test.coffee#L12-L19)
and run

    npm test

Everything works except for one thing: clicking the blue button. And I have no idea why it doesn't. When the test times out it automatically makes a screenshot of the browser session for you to check out.
Pull Requests are very welcome!

And now go ahead and write some Google API wrapers!

-- Jan
