_ = require "underscore"

TAG = "Video List"
lasurl = "http://steen.informatik.rwth-aachen.de:9914/"
appCode = "vc"
allowSendGetLasInfo = true

videoURLs = null
thumbnailsURLs = null
videoNames = new Array()
uploaderNames = new Array()

onLogout = () ->
  console.log("on logout. login status:" + lasClient.getStatus())
  videoURLs = null
  thumbnailsURLs = null
  videoNames = Array()
  uploaderNames = Array()
onLogin = ()->

class Sevianno
  constructor: ()->
    @lasClient = new LasAjaxClient "sevianno", (statusCode, message)=>
      console.log "Sevianno-Next statusCode received las: #{statusCode}/#{if _.isString message then message}"
      @lasHandler[statusCode]?.map (f)->
        f statusCode, message

    @lasHandler = []
    @iwcHandler = []

    @duiClient = new DUIClient()
    @duiClient.connect (intent)=>
      console.log "Sevianno-Next intent received iwc: #{JSON.stringify(intent)}"
      console.log "#{JSON.stringify(@iwcHandler)}"
      @iwcHandler[intent.action]?.map (f)->
        f intent

    onFinish = (intent)->
        if @lasClient.getStatus() is not "loggedIn" and allowSendGetLasInfo

          lasIntent =
            action: "GET_LAS_INFO"
            component: ""
            data: ""
            dataType: ""
          duiClient.publishToUser(lasIntent)

    @duiClient.finishMigration = onFinish
    @duiClient.updateState = onFinish
    @duiClient.initOK()


    @lasClient.verifyStatus()
    if @lasClient.getStatus() is not "loggedIn"
      onLogout()

    @registerLasFeedbackHandler Enums.Feedback.LoginSuccess, ()->
      onLogin()

    @registerLasFeedbackHandler Enums.Feedback.LogoutSuccess, ()->
      onLogout()

    @registerLasFeedbackHandler Enums.Feedback.LoginError, ()->
      alert "Login failed! Message: #{message}"

    @registerLasFeedbackHandler Enums.Feedback.LogoutError, ()->
      alert "Logout failed! Message: #{message}"

    @registerIwcCallback "ACTION_LOGOUT", (intent)->
      if intent.data? and intent.dataType is "text/html"
        lasClient.logout()
        console.log "logged out"
        allowSendGetLasInfo = true

    @registerIwcCallback "LAS_INFO", (intent)=>
      allowSendGetLasInfo = false
      if @lasClient.getStatus() is not "loggedIn" and intent.extras? and intent.extras.userName? and intent.extras.session?
        @lasClient.setCustomSessionData(intent.extras.session, intent.extras.userName, lasurl, appCode)

    @registerIwcCallback "RESTORE_LAS_SESSION", (intent)=>
      if @lasClient.getStatus() is "loggedIn"
        userName = @lasClient.getUsername()
        sessionId = @lasClient.getSessionId()
        sessionInfo =
          userName: userName
          session: sessionId

        resIntent =
          action: "LAS_SESSION"
          component: ""
          data: ""
          dataType: ""
          extras: sessionInfo

        @duiClient.publishToUser(resIntent)

  # Register new las feedback handler which listens to $statusCode. It is possible to add multiple handlers
  # for one statusCode. $f is executed with: f(statusCode, message)
  registerLasFeedbackHandler: (statusCode, f) ->
    @lasHandler[statusCode] ?= []
    @lasHandler[statusCode].push f


  registerIwcCallback: (actionName, f)->
    @iwcHandler[actionName] ?= []
    @iwcHandler[actionName].push f

  sendIwcIntent: (intent)->
      if iwc.util.validateIntent intent
        @duiClient.sendIntent intent
      else
        alert "Intent not valid!"

  lasInvocationHelper: (service, method, parameters..., callback)->
    parametersJson = new Array()
    for p in parameters
        if _.isString p
          parametersJson.push {
              type : "String"
              value: p
            }
        else if _.isArray(p) and _.isEmpty(p) or _.isString(p[0])
          parametersJson.push {
              type : "String[]"
              value: p
            }
        else if _.isObject p
          parametersJson.push p
        else
          throw new  Error "This parameter cannot be determined: #{JSON.stringify p}"
    @lasClient.invoke service, method, parametersJson, callback


  getVideoInformation: ()->
    # parameters of this function are dynamic, thus check $arguments
    uris = null
    uri_s = null
    callback = null
    switch
      when arguments.length is 1
        callback = arguments[0]
        uri_s = []
      else
        callback = arguments[1]
        uri_s = arguments[0]
    # define uris
    switch
      when _.isString uri_s then uris = [uri_s]
      when _.isArray uri_s then uris = uri_s
      else throw new Error "Invalid arguments for this function"

    # just for specific uris
    if uris.length > 0
      whereCondition = _.reduce uris[1..], (memo, url)->
          memo.concat " or $uri = '#{url}'"
        , "$uri = '#{uris[0]}'"
    # for every uri
    else
      whereCondition = ""

    @lasInvocationHelper "videoinformation", "getVideoInformationConditional", "", "", whereCondition, "", (status, result)->
      if status is 200
        callback result.value
      else throw new Error "Received status code #{statusCode}"

  getVideoAnnotations: (uri)->
    @getVideoInformation uri, (videoinformation)=>
      $videoinformation = $($.parseXML videoinformation)
      annotations = for id in $videoinformation.find("semanticRefId")
          return  $(id).text()
      throw new Error "#{annotations[0]}"


module.exports = Sevianno
