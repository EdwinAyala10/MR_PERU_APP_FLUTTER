should = require("chai").should()
request = require("request")
config = require("../config/config.js")
gAuth = require("../index.js")(config)
{inspect} = require 'util'

describe "Google Oauth", ->
    auth_code = undefined
    refresh_token = undefined
    access_token = undefined
    
    # describe "#authorizeApplication()", ->
    #     it "Responds with authorization code", (done) ->
    #         gAuth.authorizeApplication config.username, config.password, config.scope,(err, code) ->
    #             should.not.exist err
    #             should.exist code
    #             code.should.be.a "string"
    #             auth_code = code
    #             done()

    describe "#getAuthCode()", ->
        it "Responds with authorization code", (done) ->
            gAuth.getAuthCode config.scope, (err, code) ->
                should.not.exist err
                should.exist code
                code.should.be.a "string"
                auth_code = code
                done()
    
    describe "#getTokensForAuthCode()", ->
        it "Respond with an access token and a refresh token", (done) ->
            gAuth.getTokensForAuthCode auth_code, (err, body) ->
                should.not.exist err
                should.exist body
                body.should.be.an "object"
                console.log inspect body
                
                should.exist body.access_token
                should.exist body.refresh_token
                
                refresh_token = body.refresh_token
                
                done()
    
    describe "#getAccessTokenForRefreshToken()", ->
        it "Respond with new access token and expiration time", (done) ->
            gAuth.getAccessTokenForRefreshToken refresh_token, (err, body) ->
                should.not.exist err

                should.exist body
                body.should.be.an "object"

                should.exist body.access_token
                body.access_token.should.be.a "string"
                
                should.exist body.token_type
                body.token_type.should.equal 'Bearer'
                
                should.exist body.expires_in
                body.expires_in.should.be.a "number"
                body.expires_in.should.be.above 0
                
                done()
