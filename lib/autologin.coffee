module.exports = (sevianno)->
  lasuser = null
  loginform = '''
  <div id="loginModal" class="on-logout modal show" tabindex="-1" role="dialog" aria-hidden="true">
      <div class="on-logout modal-dialog">
        <div class="on-logout modal-content">
          <div class="modal-header">
            <img src="http://127.0.0.1:1337/images/sevianno_small.png" alt="Sevianno"></img>
          </div
          <div class="modal-body">
              <form id="sevianno-login-form" class="form col-md-12 center-block">
                <div class="form-group">
                  <input type="text" class="form-control input-sm" placeholder="Username">
                </div>
                <div class="form-group">
                  <input type="password" class="form-control input-sm" placeholder="Password">
                </div>
                <div class="form-group">
                  <button class="btn btn-primary btn-sm btn-block">Sign In</button>
                  <span class="pull-right"><a href="http://vermeer.informatik.rwth-aachen.de:9080/LASRegistration/index.jsp" target="_blank">Register</a></span>
                  <!--span><a href="http://tosini.informatik.rwth-aachen.de:8134/media/SeViAnno.html">Website</a></span-->
                  <span>&nbsp;</span>
                </div>
              </form>
          </div>
        </div>
      </div>
    </div>
  '''
  $("#sevianno-login").append(loginform).addClass('on-logout')
  $("#sevianno-login-form").submit (event)->
    event.preventDefault()
    lasuser = $(this).find('input[placeholder=Username]').val()
    password = $(this).find('input[placeholder=Password]').val()
    sevianno.login lasuser, password

  sevianno.registerLasFeedbackHandler Enums.Feedback.LogoutSuccess, ()->


  sevianno.registerLasFeedbackHandler Enums.Feedback.LoginSuccess, ()->
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


