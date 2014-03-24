Sevianno = require "./sevianno.coffee"

sevianno = new Sevianno()

loginForm = new FormData()
loginForm.append 'user', 'aarij'
loginForm.append 'password', 'test123'

$.ajax
  url: 'http://137.226.58.21:8080/ClViTra_2.0/rest/ClViTra/videos'
  data: loginForm,
  processData: false,
  type:        'POST',
  contentType: false,
  success: (data)->
    console.log "success #{data}"
  error: (err)->
    console.log "error #{err}"

console.log "dtrn"
$('button').click ()-> console.log "dtrn"
