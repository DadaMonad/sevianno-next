Sevianno = require "./sevianno.coffee"

sevianno = new Sevianno()

credentials = do ()->
  user = "aarij"
  password = "test123"
  hash = $.base64.encode("#{user.toLowerCase()}:#{password}")
  return "Basic " + hash

f = ()->

  $.ajax
    url: 'http://137.226.58.21:8080/ClViTra_2.0/rest/ClViTra/auth'
    type: "GET"
    dataType: "json"
    beforeSend: (xhr)->
      xhr.setRequestHeader 'Authorization', credentials

    success: (data)->
      console.log "success: #{JSON.stringify(data)}"
    error: (err)->
      console.log "error: #{JSON.stringify(err)}"

console.log "dtrn"
$('button').click f
