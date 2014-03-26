module.exports = (sevianno)->
  lasuser = null

  $("#sevianno-login-form").submit (event)->
    event.preventDefault()
    lasuser = $(this).find('input[placeholder=Username]').val()
    password = $(this).find('input[placeholder=Password]').val()
    sevianno.login lasuser, password



  sevianno.registerLasFeedbackHandler Enums.Feedback.LogoutSuccess, ()->
    $(".on-login").each ()->
      $(@).css('display','none')
    $(".on-logout").each ()->
      $(@).css('display','block')
    $('#loginModal').addClass('show')

  sevianno.registerLasFeedbackHandler Enums.Feedback.LoginSuccess, ()->
    $(".on-login").each ()->
      $(@).css('display', 'block')
    $(".on-logout").each ()->
      $(@).css('display', 'none')
    $('#loginModal').removeClass('show')

    sessionId = sevianno.lasClient.getSessionId()

    serviceName= "xmldbxs-context-service"
    methodName ="instantiateContext"
    parametersAsJSONArray = new Array()
    parametersAsJSONArray[0] = {"type": "String", "value": "vc"}
    parametersAsJSONArray[1] = {"type": "String", "value": "v2"}
    sevianno.lasClient.invoke serviceName, methodName, parametersAsJSONArray, ()->

    ###
		user = lasClient.getUsername();

    intent =
      "component":""
      "action":"ACTION_LOGIN"
      "data":"http://example.org"
      "dataType":"text/html"
      "categories":["example1","example2"]
      "flags":["PUBLISH_LOCAL"]
      "extras":{"sessionId":sessionId, "user":user}

    sevianno.sendIwcIntent(intent)
    ###

    intent =
      "component":""
      "action":"LAS_INFO"
      "data":""
      "dataType":""
      "extras":{"session":sessionId, "userName":lasuser}

    sevianno.duiClient.publishToUser(intent)


