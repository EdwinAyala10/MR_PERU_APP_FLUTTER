page = require('webpage').create()
system = require('system')

debug = true
jqueryURI = "http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"

if debug
    page.onConsoleMessage = (msg) -> console.log(msg)
    page.onAlert = (msg) -> console.log(msg)

    #page.onResourceRequested = (request) ->
    #    console.log 'Request ' + JSON.stringify request, undefined, 4
    #    console.log request.url
    #page.onResourceReceived = (response) ->
    #    console.log 'Receive ' + JSON.stringify response, undefined, 4

page.onUrlChanged = (url) ->
    #console.log "new url: #{url}"
    if /settings\/account/.test url
        console.log "logged in #{system.args[1]}"
        followUpURI = system.args[3]
        # do on next tick (to prevent from crashing when exit is called from an event handler)
        setTimeout ->
            confirmPermissions followUpURI
        , 1

page.open "https://accounts.google.com/ServiceLogin", (status) ->
    if status is "success"
        page.includeJs jqueryURI, ->
            page.evaluate (username, password) ->
                #alert "* Script running in the Page context."
                $("input").each ->
                    console.log "input", $(this).attr("type"), this.id, this.name, $(this).val()
                $("input[type=email]").val(username)
                $("input[type=password]").val(password)
                $("input[type=submit]").click()
            , system.args[1], system.args[2]

        setTimeout ->
            page.render "timeoui.png"
            console.log("TIMEOUT! See timeout.png.")
            phantom.exit 1
        , 15000
            
    else
        console.log "... fail! Check the $PWD?!"
        phantom.exit 1
        
confirmPermissions = (uri) ->
    console.log "navigating to: #{uri}"
    
    confirmPage = require('webpage').create()
    confirmPage.onConsoleMessage = (msg) -> console.log(msg)
    confirmPage.onAlert = (msg) -> console.log(msg)
    confirmPage.onUrlChanged = (url) ->
        console.log "*NEW* confirm url #{url}"
        
    confirmPage.open uri, (status) ->
        console.log status
        if status isnt "success"
            console.log "page failed to load, see fail.png"
            confirmPage.render "fail.png"
            phantom.exit 1

        pos = null
        
        confirmPage.includeJs jqueryURI, ->
            pos = confirmPage.evaluate ->
                $("button").each ->
                    console.log "button", $(this).attr("type"), this.id, this.name, $(this).val()
                
                button = $('#submit_approve_access').first()
                {left, top} = button.offset()
                [width, height] = [button.width(), button.height()]
                
                # window.setTimeout ->
                #      #button[0].click()
                #      #document.location.href = "http://localhost:3000/callback?code=4/evxJ1gaSk09OOmvtw1y3V5avi-gB.Ahort6xHLlYTOl05ti8ZT3a3ER_2eAI"
                # , 1000
                
                return {
                    x: Math.round left + width/2
                    y: Math.round top + height/2
                }
            
        setTimeout ->
            console.log "approving by clicking at", pos.x, pos.y
            # confirmPage.sendEvent 'mousedown', pos.x, pos.y, "left"
            # confirmPage.sendEvent 'mouseup', pos.x, pos.y, "left"
            confirmPage.sendEvent 'click', pos.x, pos.y
        , 2000
        
            
        # setTimeout ->
        #     confirmPage.render "timeoui.png"
        #     console.log("TIMEOUT while approving! See timeout.png.")
        #     phantom.exit 1
        # , 8000
