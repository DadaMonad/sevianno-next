g = function() {
  var date, videoinfo_meat;
  date = dateFormat(new Date(), "ddd mmm dd HH:mm:ss Z yyyy");
  date = "Wed Mar 26 01:57:29 CET 2014"
  videoinfo_meat = "<?xml version='1.0' standalone='yes'?><video><title>TheName</title><creator>ClViTra</creator><video_uri>http://videourl</video_uri><created_at>" + date + "</created_at><thumb_image>http://dtrn</thumb_image><keywords><keyword>ClViTra transcoded</keyword></keywords><annotations></annotations></video>";
  return sevianno.lasInvocationHelper("mpeg7_multimediacontent_service", "addVideoInformations", videoinfo_meat, function(v) {
    return console.log("We transcoded over " + v + "!!!!!!!!!!!");
  });
};
