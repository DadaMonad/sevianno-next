Sevianno = require "./sevianno.coffee"
dateFormat = require "dateformat"

sevianno = new Sevianno(require('./autologin.coffee'))

credentials = do ()->
  user = "aarij"
  password = "test123"
  hash = $.base64.encode("#{user.toLowerCase()}:#{password}")
  return "Basic " + hash


$.ajax
      url: 'http://137.226.58.21:9080/ClViTra_2.0/rest/auth'
      type: "GET"
      dataType: "json"
      beforeSend: (xhr)->
        xhr.setRequestHeader 'Authorization', credentials

      success: (data)->
        console.log "success: #{JSON.stringify(data)}"
      error: (err)->
        console.log "error: #{JSON.stringify(err)}"

$.ajax
    url: "http://137.226.58.21:9080/ClViTra_2.0/rest/videos"
    type: "GET"
    dataType: "json"

    success: (data)->
      console.log "success vid: #{JSON.stringify(data)}"
    error: (err)->
      console.log "error vid: #{JSON.stringify(err)}"

vidCounter = 0
vidCounterUploaded = 0
vidCounterTranscoded = 0

sevianno.registerIwcCallback "ADDED_TO_MPEG7", (intent)->
  [name, videourl, thumbnail] = intent.extras.videoDetails.split("%")
  date = dateFormat(new Date(), "ddd mmm dd HH:mm:ss Z yyyy")
  vidCounterTranscoded++
  $("#vidnumber#{vidCounterTranscoded}").text("Uploaded: #{name}").click ()->
    window.open("#{videourl}",'_blank')


  videoinfo_meat = """
<?xml version='1.0' standalone='yes'?>
<video>
<title>#{name}</title>
<creator>ClViTra</creator>
<video_uri>#{videourl}</video_uri>
<created_at>#{date}</created_at>
<thumb_image>#{thumbnail}</thumb_image>
<keywords>
<keyword>ClViTra transcoded</keyword>
</keywords>
<annotations>
</annotations>
</video>
"""
  sevianno.lasInvocationHelper "mpeg7_multimediacontent_service", "addVideoInformations", videoinfo_meat, (v)->
    console.log "We transcoded over #{v}!!!!!!!!!!!"

g = ()->
  date = dateFormat(new Date(), "ddd mmm dd HH:mm:ss Z yyyy")
  sevianno.lasInvocationHelper "mpeg7_multimediacontent_service", "addVideoInformations", videoinfo_meat, (v)->
    console.log "We transcoded over #{v}!!!!!!!!!!!"


$("#video-upload-form").submit (event)->
    vidCounter++
    $("#vids").append("<button id='vidnumber#{vidCounter}' info class='btn btn-info' style='width: 100%'>Uploading..</button>")

    event.preventDefault()
    formData = new FormData($("#video-upload-form")[0])

    $.ajax
      url: "http://137.226.58.21:9080/ClViTra_2.0/rest/upload"
      type: "POST"
      processData: false
      contentType: false
      data: formData
      success: (data)->
        vidCounterUploaded++
        $("#vidnumber#{vidCounterUploaded}").text("Transcoding..")
        console.log "success upload: #{JSON.stringify(data)}"
      error: (err)->
        vidCounterUploaded++
        $("#vidnumber#{vidCounterUploaded}").text("Upload Failed")
        console.log "error upload: #{JSON.stringify(err)}"

