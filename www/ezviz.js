/*global cordova, module*/

module.exports = {
        greet: function (name, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "ezviz", "greet", [name]);
    },
    init:function(accessToken){
        cordova.exec(function(){},
            function(error){
                console.log('list camera error:',error);
            },
            "ezviz",
            "init",
            [accessToken]);
    },
    listCamera:function(successCallback,errorCallback){
        cordova.exec(function(){}, function(error){
            console.log('list camera error:',error);
        }, "ezviz", "listCamera", []);
    },
    preview:function(accessToken,deviceSerial,cameraIndex,eventName,doorCaption,lightCaption,successCallback,errorCallback){
        cordova.exec(successCallback || function(){},
            errorCallback || function(error){   console.log('open camera error:',error);},
            "ezviz",
            "preview",
            [accessToken||"",deviceSerial,cameraIndex || 0,eventName || "",doorCaption || "",lightCaption || ""]);
    }
};
