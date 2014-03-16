module.exports = do ()->
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
	onLogout = ()->
		
	
	class Sevianno
		constructor: ()->
			@lasClient = new LasAjaxClient "sevianno", @lasFeedbackHandlerRoutine
			@lasHandler = []
			
			@duiClient = new DUIClient()
			@duiClient.connect @iwcCallbackRoutine
			@iwcHandler = []

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
				idsArray = getMpeg7MediaIds()
			
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
					@lasClient.setCustomSessionData(intent.extras.session, intent.extras.userName, lasurl, appCode);		
		
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
		
		lasFeedbackHandlerRoutine: (statusCode, message)=>
			@lasHandler[statusCode]?.map (f)->
				f statusCode, message
		
		registerIwcCallback: (actionName, f)->
			@iwcHandler[actionName] ?= []
			@iwcHandler[actionName].push f
		
		iwcCallbackRoutine: (intent)=>
			@lasHandler[intent.action]?.map (f)->
				f intent
		
		sendIwcIntent: (intent)->
				if iwc.util.validateIntent intent
					@duiClient.sendIntent intent
				else
					alert "Intent not valid!"
	
	return Sevianno