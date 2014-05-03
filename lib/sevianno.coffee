_ = require "underscore"

lasurl = "http://steen.informatik.rwth-aachen.de:9914/"
appCode = "sevianno-next"
lasuser = null

allowSendGetLasInfo = true

videoURLs = null
thumbnailsURLs = null
videoNames = new Array()
uploaderNames = new Array()

onLogout = () ->
  videoURLs = null
  thumbnailsURLs = null
  videoNames = Array()
  uploaderNames = Array()
  $(".on-login").each ()->
    $(@).css('display','none')
  $(".on-logout").each ()->
    $(@).css('display','block')
  $('#loginModal').addClass('show')


onLogin = ()->
  $(".on-login").each ()->
    $(@).css('display', 'block')
  $(".on-logout").each ()->
    $(@).css('display', 'none')
  $('#loginModal').removeClass('show')

# This is the class that all sevianno tools use. After initialization a
# - iwc Client is initialized
# - las Client is initialized
# - log in / out
# It provides some convenient wrappers of functions.
class Sevianno
  # Initialized lasClient
  # @example
  #   lasClient.invoke(service, method, parametersJson, callback)
  lasClient: ()->

  # Initialized duiClient
  # @example
  duiClient: ()->

  # If you need to execute tasks after the initialization of Sevianno add them as arguments
  # The parameter of the function is the context of Sevianno initialization (this)
  # @example
  #   af1 = f2 = function(sevianno){ console.log(sevianno)}
  #   new Sevianno(f1, f2)


  constructor: (execute_after_init...)->
    @lasClient = new LasAjaxClient "sevianno", (statusCode, message)=>
      console.log "Sevianno-Next statusCode received las: #{statusCode}/#{if _.isString message then message}"
      @lasHandler[statusCode]?.map (f)->
        f statusCode, message
    # This is also there
    @lasHandler = []
    @iwcHandler = []

    @duiClient = new DUIClient()
    @duiClient.connect (intent)=>
      console.log "Sevianno-Next intent received iwc: #{JSON.stringify(intent)}"
      console.log "#{JSON.stringify(@iwcHandler)}"
      @iwcHandler[intent.action]?.map (f)->
        setTimeout ()->
            f intent
          , 0
    onFinish = (intent)=>
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

    @registerLasFeedbackHandler Enums.Feedback.LoginSuccess, onLogin

    @registerLasFeedbackHandler Enums.Feedback.LogoutSuccess, onLogout

    @registerLasFeedbackHandler Enums.Feedback.LoginError, ()->
      alert "Login failed! Message: #{message}"

    @registerLasFeedbackHandler Enums.Feedback.LogoutError, ()->
      alert "Logout failed! Message: #{message}"

    @registerIwcCallback "ACTION_LOGOUT", (intent)=>
      if intent.data? and intent.dataType is "text/html"
        try
          @lasClient.logout()
          do ()->
        catch e
          console.log "Logout error: #{e}"
        finally
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

    if(execute_after_init?)
      _.map execute_after_init, (f)=>
        f(@)

  # Register new las feedback handler which listens to $statusCode. It is possible to add multiple handlers
  # for one statusCode. $f is executed with: f(statusCode, message)
  # @example
  #   registerLasFeedbackHandler 'LoginSuccess', onLogin
  registerLasFeedbackHandler: (statusCode, f) ->
    @lasHandler[statusCode] ?= []
    @lasHandler[statusCode].push f

  # Register new iwc feedback handler which listens to $actionName. It is possible to add multiple handlers
  # for one action name. $f is executed with: f(statusCode, message)
  # @example
  #   registerLasFeedbackHandler('LoginSuccess', function(statusCode, message){})
  registerIwcCallback: (actionName, f)->
    if(_.isArray actionName)
      _.map actionName, (a)=>@registerIwcCallback(a, f)
    else
      @iwcHandler[actionName] ?= []
      @iwcHandler[actionName].push f

  # Publish an iwc intent
  # @example
  #   intent = {
  #     "component":"",
  #     "action":"ACTION_LOGIN",
  #     "data":"http://example.org",
  #     "dataType":"text/html",
  #     "categories":["example1","example2"],
  #     "flags":["PUBLISH_LOCAL"],
  #     "extras":{"sessionId":sessionId, "user":user}
  #   }
  #   sendIwcIntent(intent)
  sendIwcIntent: (intent)->
      if iwc.util.validateIntent intent
        @duiClient.sendIntent intent
      else
        alert "Intent not valid!"
  # Login to las
  #
  # Used by the login widget
  login: (user, password)->
    @lasClient.login(user, password, lasurl, appCode)


  # Invoke a service on las
  # @example
  #   sevianno.lasInvocationHelper("mpeg7_multimediacontent_service"
  #                               , "addVideoInformations"
  #                               , param1
  #                               , param2
  #                               , function(result){} )
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

  # Get all the videoinformation in the database. A 'videoinformation' is a string encoded xml. Parse it e.g.
  # with jquery. For more information about a 'videoinformation' consult the documentation of the las library.
  # @see http://dbis.rwth-aachen.de/~jahns/javadocs/videoinformation/
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

    @lasInvocationHelper "videoinformation", "getVideoInformationConditional", "", "", whereCondition, "", (statusCode, result)->
      if statusCode is 200
        callback result.value
      else throw new Error "Received bad status code #{statusCode}"

  # Get all annotations of a video/videos
  # @return {JSON} An object with properties $uploader, $type, $id, $text
  #
  getVideoAnnotations: (uri, callback)->
    @getVideoInformation uri, (videoinformation)=>
      $videoinformation = $($.parseXML videoinformation)
      annotations = for a in $videoinformation.find("annotation")
        $a = $(a)
        time_in_seconds = do ()->
          std_min_sek_msek_arr = $a.find('timepoint').text().split ':'
          std_in_sek = Number(std_min_sek_msek_arr[0].slice 1)*3600
          min_in_sek = Number(std_min_sek_msek_arr[1])*60
          all_in_sek = Number(std_min_sek_msek_arr[2])+min_in_sek+std_in_sek
        [$a.find("semanticRefId").text(), time_in_seconds]

      annotations = _.filter annotations, (a)-> a[0] isnt 'undefined' and _.isNumber(a[1]) and not _.isNaN(a[1])
      annotationids = _.map annotations, (a)->a[0]
      @lasInvocationHelper "videoinformation", "getSemanticAnnotationsSet", annotationids, (statusCode, result)->
        if statusCode is 200
          annotations = _.zip annotations, result.value
          annotations = _.map annotations, ([[id, time], text])->
            # TODO: bad
            [type, rest] = id.split "_"
            #type = String.prototype.slice.call(type, 8,-4)
            uploader = null
            for i in [1..(rest.length)]
              if not _.isNaN(Number(rest[i]))
                uploader = String.prototype.slice.call(rest, 0, i)
                break
            return {
              uploader: uploader
              type: type
              id: id
              time: time
              text: text
            }
          callback annotations
        else throw new Error "Received bad status code #{statusCode}"


module.exports = Sevianno
