Sevianno = require "./sevianno.coffee"

sevianno = new Sevianno()

sevianno.registerIwcCallback "ACTION_OPEN", (intent)->
	console.log "#{intent.extras.videoUrl}"
	parametersAsJSONArray = new Array()
	parametersAsJSONArray.push {
						type : "String[]"
						value : [intent.extras.videoUrl]
					}
	sevianno.lasClient.invoke "videoinformation", "getSemanticAnnotationsSet", parametersAsJSONArray, (status, result)->
		console.log "alalalala ahhahahhahh      dtrnuiade trnd#{result.value}"
	###
	console.log "#{intent.extras.videoUrl}"
	parametersAsJSONArray = new Array intent.extras.videoUrl
	sevianno.lasClient.invoke "videoinformation", "getSemanticAnnotationsSet", parametersAsJSONArray, (status, result)->
		console.log "#{result.value}"
	###