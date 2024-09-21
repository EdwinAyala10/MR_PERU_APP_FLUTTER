request = require("request")
exec = require("child_process").exec
querystring = require("querystring")

endpoint_auth = "https://accounts.google.com/o/oauth2/auth"
endpoint_token = "https://accounts.google.com/o/oauth2/token"

module.exports = (opts) ->
    opts.redirect_uri or= "http://localhost:3000/callback"
    opts.refresh_tokens or= []
    
    ###
    Constructs a google OAuth2 request url using the provided opts.
    Spawns an http server to handle the redirect. Once user authenticates
    and the server parses the auth code, the server process is closed
    (Assuming the user has closed the window. For future, add redirect after
    authentication to a page with instructions to close tab/window).

    Some scopes:
    https://www.googleapis.com/auth/userinfo.profile
    https://www.googleapis.com/auth/drive.readonly.metadata
    ###

    getAuthCode = (scope, openURICallback, callback) ->
        if arguments.length is 2
            callback = openURICallback
            openURICallback = null
            
        # default: open the system's web browser
        openURICallback or= (uri, cb) ->
            #TODO: Make OS agnostic w/ xdg-open, open, etc.
            exec "open '#{uri}'", cb
            
        qs =
            response_type: "code"
            client_id: opts.client_id
            redirect_uri: opts.redirect_uri
            scope: scope
        
        uri = endpoint_auth + "?" + querystring.stringify(qs)
                
        console.log "Starting server ..."
        server = require("http").createServer((req, res) ->
            console.log "server receives request for", req.url
            console.log "Stopping server ..."
            server.close()
            res.end "ok"
            callback null, querystring.parse(req.url.split("?")[1]).code
        ).listen(3000)
        
        openURICallback uri, (err) ->
            if (err) then callback err
            console.log "uri opened ..."

    ###
    Given the acquired authorization code and the provided opts,
    construct a POST request to acquire the access token and refresh
    token.

    @param {String} code Can be acquired with getAuthCode
    ###
    getTokensForAuthCode = (code, callback) ->
        form =
            code: code
            client_id: opts.client_id
            client_secret: opts.client_secret
            redirect_uri: opts.redirect_uri
            grant_type: "authorization_code"

        request.post
            url: endpoint_token
            form: form
        , (err, req, body) ->
            if err? then return callback err
            callback null, JSON.parse(body)

    ###
    Given a refresh token and provided opts, returns a new
    access token. Tyically the access token is valid for an hour.

    @param {String} refresh_token The refresh token. Can be acquired
    through getTokensForAuthCode function.
    ###
    getAccessTokenForRefreshToken = (refresh_token, callback) ->
        form =
            refresh_token: refresh_token
            client_id: opts.client_id
            client_secret: opts.client_secret
            grant_type: "refresh_token"

        request.post
            url: endpoint_token
            form: form
        , (err, res, body) ->
            if err? or res.statusCode isnt 200 then return callback err or body
            callback null, JSON.parse(body)

    ###
    Given google account name and password, use phantomJS to login a user into google services.
    Afterwards navigate the browser to a given URL.
    The purpose of this is to allow a command line tool to authorize
    an application (or itself) to access the user's data.
    ###
    
    automaticGoogleWebLogin = (username, password, followUpURI, cb) ->
        childProcess = require "child_process"
        phantomjs = require "phantomjs"
        path = require "path"

        childArgs = [
            path.join(__dirname, "lib/google-login-phantomjs-script.coffee")
            username
            password
            followUpURI
        ]

        child = childProcess.spawn phantomjs.path, childArgs

        child.stdout.on "data", (data) ->
            process.stdout.write data

        child.stderr.on "data", (data) ->
            process.stderr.write data

        child.on "exit", (code) ->
            console.log "phantomjs exited with code:", code
            if code isnt 0
                return cb "phantomjs exited with code #{code}", code
            cb null
    

    authorizeApplication = (username, password, scope, cb) ->
        getAuthCode scope, (uri, cb) ->
            automaticGoogleWebLogin username, password, uri, cb
        , cb

    ### 
    Convenience dunction
    Use this to get an access token for a specific scope
    ###
    getAccessToken: (scope, cb) ->
        refresh_token = opts.refresh_tokens[scope]
        if refresh_token
            getAccessTokenForRefreshToken refresh_token, cb
        else
            async.waterfall [
                getAuthCode,
                getTokensForAuthCode
            ], (err, result) ->
                # store the refresh_token for future use
                opts.refresh_token[scope] = result?.refresh_token
                cb err, result?.access_token
    
    return {
        getAuthCode: getAuthCode
        authorizeApplication: authorizeApplication
        getTokensForAuthCode: getTokensForAuthCode
        getAccessTokenForRefreshToken: getAccessTokenForRefreshToken
    }
