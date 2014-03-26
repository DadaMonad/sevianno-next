var Sevianno = require("./sevianno.coffee");
var sevianno = new Sevianno(require('./autologin.coffee'));

var credentials = function(){
  var user = "aarij";
  var password = "test123";
  var hash = $.base64.encode(user + password);
  return "Basic " + hash;
}();

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
    $("#vids").append("<button id='uploaded-video' class='btn btn-info' style='width: 100%'>Uploading..</button>");

    event.preventDefault();
    var formData = new FormData($("#video-upload-form")[0]);

    $.ajax({
      url: "http://137.226.58.21:9080/ClViTra_2.0/rest/upload",
      type: "POST",
      processData: false,
      contentType: false,
      data: formData,
      success: function(data){
        $("#uploaded-video").text("Transcoding..");
      }
    });
});

// Iwc Handler: Listen to 'ADDED_TO_MPEG7'
sevianno.registerIwcCallback("ADDED_TO_MPEG7", function(intent){
  var parsed = intent.extras.videoDetails.split("%");
  var name = parsed[0],
      videourl = parsed[1],
      thumbnail = parsed[2];

  $("#uploaded-video").text("Uploaded: "+name).click(function(){
    window.open(""+videourl,'_blank');
  });
});










