Sevianno = require "./sevianno.coffee"
_ = require "underscore"

autologin_extension = require "./autologin.coffee"

sevianno = new Sevianno(autologin_extension)

makeResponsiveTable = ()->
  if $(window).width() < 290
    $(".sevianno-annotation-table tr th:nth-child(2)").css('display', 'none')
    $(".sevianno-annotation-table tr td:nth-child(2)").each ()->
      $(@).css('display', 'none')
    $(".sevianno-annotation-table tr th:nth-child(3)").css('display', 'none')
    $(".sevianno-annotation-table tr td:nth-child(3)").each ()->
      $(@).css('display', 'none')
  else if $(window).width() < 390
    $(".sevianno-annotation-table tr th:nth-child(2)").css('display', 'none')
    $(".sevianno-annotation-table tr td:nth-child(2)").each ()->
      $(@).css('display', 'none')
    $(".sevianno-annotation-table tr th:nth-child(3)").css('display', 'table-cell')
    $(".sevianno-annotation-table tr td:nth-child(3)").each ()->
      $(@).css('display', 'table-cell')
  else
    $(".sevianno-annotation-table tr th:nth-child(3)").css('display', 'table-cell')
    $(".sevianno-annotation-table tr td:nth-child(3)").each ()->
      $(@).css('display', 'table-cell')
    $(".sevianno-annotation-table tr th:nth-child(2)").css('display', 'table-cell')
    $(".sevianno-annotation-table tr td:nth-child(2)").each ()->
      $(@).css('display', 'table-cell')
makeResponsiveTable()

$(window).resize makeResponsiveTable

rewriteSeviannoTableContext = ()->
  makeResponsiveTable()
  $('.sevianno-annotation-entry').contextMenu 'sevianno-annotation-entry-context',
    'Edit':
      klass: "annotation-entry-edit-context"
      click: (element)->
        refAnnotation = $.parseJSON($(element[0]).attr('annotationvalue'))
        intent =
          "component" : ""
          "action" : "ACTION_UPDATE_ANNOTATIONS"
          "data" : "www.example.org"
          "dataType" : "text/html"
          "flags" : [ "PUBLISH_GLOBAL" ]
          "extras" :
            "index" : 0
            "semantic" : refAnnotation.id
            "type" : refAnnotation.type
        sevianno.duiClient.sendIntent intent
        intent =
          "component" : ""
          "action" : "ACTION_PAUSE"
          "data" : "www.example.org"
          "dataType" : "text/html"
          "flags" : [ "PUBLISH_GLOBAL" ]
        sevianno.duiClient.sendIntent intent
    'Delete':
      klass: "annotation-entry-delete-context"
      click: (element)->
        refAnnotation = $.parseJSON($(element[0]).attr('annotationvalue'))
        intent =
          "component" : ""
          "action" : "ACTION_DELETE_ANNOTATIONS"
          "data" : "www.example.org"
          "dataType" : "text/html"
          "flags" : [ "PUBLISH_GLOBAL" ]
          "extras" : {"index" : "0", "semantic" : refAnnotation.id}
        sevianno.duiClient.sendIntent intent


sevianno.registerIwcCallback ["ACTION_OPEN", "ACTION_ADD_NEW_ANNOTATION_TO_TABLE", "ACTION_END_TABLE_MODIFICATION"], do ()->
  video_uri = null # private variable
  (intent)->
    if(intent.action is "ACTION_OPEN")
      video_uri = intent.extras.videoUrl
    $annotation_table = $($(".sevianno-annotation-table").find("tbody"))
    $annotation_table.empty()
    $annotation_table.append("<tr class='info'><td>Loading...</td><td></td><td></td></tr>")

    sevianno.getVideoAnnotations video_uri, (annotations)->
      $annotation_table.empty()
      for annotation in annotations
        atime = annotation.time
        thetime = null
        if atime >= 60
          thetime = "#{Math.floor(atime/60)} min #{atime % 60} sec"
        else
          thetime = "#{atime % 60} sec"

        $annotation_table.append("<tr class='sevianno-annotation-entry' annotationvalue='#{JSON.stringify annotation}'><td>#{annotation.text}</td><td>#{annotation.uploader}</td><td>#{thetime}</td></tr>")
      rewriteSeviannoTableContext()
      $(".sevianno-annotation-entry").each ()->
        annotationtime = $.parseJSON($(@).attr("annotationvalue")).time
        iwcintent =
          "component" : ""
          "action" : "ACTION_SEEK"
          "data" : video_uri
          "dataType" : "video/mp4"
          "flags" : [ "PUBLISH_GLOBAL" ]
          "extras" :
            "position" : annotationtime
        $(@).click ->
          sevianno.sendIwcIntent iwcintent

    sevianno.getVideoInformation video_uri, (videoinformation)->
      console.log "VideoInformation: #{videoinformation}"


sevianno.registerIwcCallback "ACTION_SEND_SEARCH_ANNOTATIONS_AT_TIME", (intent)->
  $annotation_table = $($(".sevianno-annotation-table").find("tbody"))
  [mm,sek] = intent.extras.time.split(":")
  currentvideotime = Number(mm)*60 + Number(sek)

  $(".sevianno-annotation-table").find(".sevianno-annotation-entry").each ()->
    mytime = $.parseJSON($(@).attr("annotationvalue")).time
    if mytime is currentvideotime
      $(@).addClass("success")
    else
      $(@).removeClass("success")


