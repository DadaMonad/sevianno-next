(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Sevianno, sevianno;

Sevianno = require("./sevianno.coffee");

sevianno = new Sevianno();

sevianno.registerIwcCallback("ACTION_OPEN", function(intent) {
  var parametersAsJSONArray;
  console.log("" + intent.extras.videoUrl);
  parametersAsJSONArray = new Array();
  parametersAsJSONArray.push({
    type: "String[]",
    value: [intent.extras.videoUrl]
  });
  return sevianno.lasClient.invoke("videoinformation", "getSemanticAnnotationsSet", parametersAsJSONArray, function(status, result) {
    return console.log("alalalala ahhahahhahh      dtrnuiade trnd" + result.value);
  });

  /*
  console.log "#{intent.extras.videoUrl}"
  parametersAsJSONArray = new Array intent.extras.videoUrl
  sevianno.lasClient.invoke "videoinformation", "getSemanticAnnotationsSet", parametersAsJSONArray, (status, result)->
    console.log "#{result.value}"
   */
});


},{"./sevianno.coffee":2}],2:[function(require,module,exports){
var Sevianno, TAG, allowSendGetLasInfo, appCode, lasurl, onLogin, onLogout, thumbnailsURLs, uploaderNames, videoNames, videoURLs;

TAG = "Video List";

lasurl = "http://steen.informatik.rwth-aachen.de:9914/";

appCode = "vc";

allowSendGetLasInfo = true;

videoURLs = null;

thumbnailsURLs = null;

videoNames = new Array();

uploaderNames = new Array();

onLogout = function() {
  console.log("on logout. login status:" + lasClient.getStatus());
  videoURLs = null;
  thumbnailsURLs = null;
  videoNames = Array();
  return uploaderNames = Array();
};

onLogin = function() {};

Sevianno = (function() {
  function Sevianno() {
    var onFinish;
    this.lasClient = new LasAjaxClient("sevianno", (function(_this) {
      return function(statusCode, message) {
        var _ref;
        console.log("Sevianno-Next statusCode received las: " + statusCode);
        return (_ref = _this.lasHandler[statusCode]) != null ? _ref.map(function(f) {
          return f(statusCode, message);
        }) : void 0;
      };
    })(this));
    this.lasHandler = [];
    this.iwcHandler = [];
    this.duiClient = new DUIClient();
    this.duiClient.connect((function(_this) {
      return function(intent) {
        var _ref;
        console.log("Sevianno-Next intent received iwc: " + (JSON.stringify(intent)));
        console.log("" + (JSON.stringify(_this.iwcHandler)));
        return (_ref = _this.iwcHandler[intent.action]) != null ? _ref.map(function(f) {
          return f(intent);
        }) : void 0;
      };
    })(this));
    onFinish = function(intent) {
      var lasIntent;
      if (this.lasClient.getStatus() === !"loggedIn" && allowSendGetLasInfo) {
        lasIntent = {
          action: "GET_LAS_INFO",
          component: "",
          data: "",
          dataType: ""
        };
        return duiClient.publishToUser(lasIntent);
      }
    };
    this.duiClient.finishMigration = onFinish;
    this.duiClient.updateState = onFinish;
    this.duiClient.initOK();
    this.lasClient.verifyStatus();
    if (this.lasClient.getStatus() === !"loggedIn") {
      onLogout();
    }
    this.registerLasFeedbackHandler(Enums.Feedback.LoginSuccess, function() {
      return onLogin();
    });
    this.registerLasFeedbackHandler(Enums.Feedback.LogoutSuccess, function() {
      return onLogout();
    });
    this.registerLasFeedbackHandler(Enums.Feedback.LoginError, function() {
      return alert("Login failed! Message: " + message);
    });
    this.registerLasFeedbackHandler(Enums.Feedback.LogoutError, function() {
      return alert("Logout failed! Message: " + message);
    });
    this.registerIwcCallback("ACTION_LOGOUT", function(intent) {
      if ((intent.data != null) && intent.dataType === "text/html") {
        lasClient.logout();
        console.log("logged out");
        return allowSendGetLasInfo = true;
      }
    });
    this.registerIwcCallback("LAS_INFO", (function(_this) {
      return function(intent) {
        allowSendGetLasInfo = false;
        if (_this.lasClient.getStatus() === !"loggedIn" && (intent.extras != null) && (intent.extras.userName != null) && (intent.extras.session != null)) {
          return _this.lasClient.setCustomSessionData(intent.extras.session, intent.extras.userName, lasurl, appCode);
        }
      };
    })(this));
    this.registerIwcCallback("RESTORE_LAS_SESSION", (function(_this) {
      return function(intent) {
        var resIntent, sessionId, sessionInfo, userName;
        if (_this.lasClient.getStatus() === "loggedIn") {
          userName = _this.lasClient.getUsername();
          sessionId = _this.lasClient.getSessionId();
          sessionInfo = {
            userName: userName,
            session: sessionId
          };
          resIntent = {
            action: "LAS_SESSION",
            component: "",
            data: "",
            dataType: "",
            extras: sessionInfo
          };
          return _this.duiClient.publishToUser(resIntent);
        }
      };
    })(this));
  }

  Sevianno.prototype.registerLasFeedbackHandler = function(statusCode, f) {
    var _base;
    if ((_base = this.lasHandler)[statusCode] == null) {
      _base[statusCode] = [];
    }
    return this.lasHandler[statusCode].push(f);
  };

  Sevianno.prototype.registerIwcCallback = function(actionName, f) {
    var _base;
    if ((_base = this.iwcHandler)[actionName] == null) {
      _base[actionName] = [];
    }
    return this.iwcHandler[actionName].push(f);
  };

  Sevianno.prototype.sendIwcIntent = function(intent) {
    if (iwc.util.validateIntent(intent)) {
      return this.duiClient.sendIntent(intent);
    } else {
      return alert("Intent not valid!");
    }
  };

  return Sevianno;

})();

module.exports = Sevianno;


},{}]},{},[1])