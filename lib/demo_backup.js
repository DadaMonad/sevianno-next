var Sevianno = require("./sevianno.coffee");
var sevianno = new Sevianno(require('./autologin.coffee'));

var credentials = (function() {
  var user = "aarij",
      password = "test123",
      hash = $.base64.encode("" + user + ":" + password); // jquery.base64 plugin
  return "Basic " + hash;
})();

// Login to ClViTra
$.ajax({
      url: 'http://137.226.58.21:9080/ClViTra_2.0/rest/auth',
      type: "GET",
      dataType: "json",
      beforeSend: function(xhr){
        xhr.setRequestHeader('Authorization', credentials);
      },
      success: function(data){
        console.log("You successfully logged in");
      }
});

// Overwrite form submit
$("#video-upload-form").submit(function(event){
    event.preventDefault();

    $("#vids").append("<button id='uploaded-video' class='btn btn-info' style='width: 100%'>Uploading..</button>");

    var formData = new FormData($("#video-upload-form")[0]);

    $.ajax({
      url: "http://137.226.58.21:9080/ClViTra_2.0/rest/upload",
      type: "POST",
      data: formData,
      processData: false,
      contentType: false,
      success: function(data){
        $("#uploaded-video").text("Transcoding..");
      }
    });
});

// Iwc Handler: Listen to 'ADDED_TO_MPEG7'
sevianno.registerIwcCallback("ADDED_TO_MPEG7", function(intent){
  var parse = intent.extras.videoDetails.split("%"),
      name = parse[0],
      link_to_video = parse[1],
      link_to_thumbnail = parse[2];

  $("#uploaded-video").text("Uploaded: "+name).click(function(){
    window.open(""+link_to_video,'_blank');
  });
});










