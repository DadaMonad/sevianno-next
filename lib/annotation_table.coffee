Sevianno = require "./sevianno.coffee"
_ = require "underscore"

sevianno = new Sevianno()

sevianno.registerIwcCallback "ACTION_OPEN", (intent)->
  $annotation_table = $($(".sevianno-annotation-table").find("tbody"))
  $annotation_table.empty()
  $annotation_table.append("<tr class='info'><td>Loading...</td><td></td></tr>")


  sevianno.getVideoAnnotations intent.extras.videoUrl, (annotations)->
    $annotation_table.empty()
    for annotation in annotations
      atime = annotation.time
      thetime = null
      if atime >= 60
        thetime = "#{Math.floor(atime/60)} min #{atime % 60} sec"
      else
        thetime = "#{atime % 60} sec"

      $annotation_table.append("<tr class='sevianno-annotation-entry' annotationvalue='#{JSON.stringify annotation}'><td>#{annotation.text}</td><td>#{thetime}</td></tr>")

    $(".sevianno-annotation-entry").each ()->
      annotationtime = $.parseJSON($(@).attr("annotationvalue")).time
      iwcintent =
        "component" : ""
        "action" : "ACTION_SEEK"
        "data" : intent.extras.videoUrl
        "dataType" : "video/mp4"
        "flags" : [ "PUBLISH_GLOBAL" ]
        "extras" :
          "position" : annotationtime
      $(@).click ->
        sevianno.sendIwcIntent iwcintent

  sevianno.getVideoInformation intent.extras.videoUrl, (videoinformation)->
    console.log "VideoInformation: #{videoinformation}"
