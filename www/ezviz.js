
/*global cordova, module*/

module.exports = {
    greet: function (name, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Hello", "greet", [name]);
    },
        init:function(accessToken,telNo){

               cordova.exec(function(){}, function(error){
                                                             console.log('list camera error:',error);
                                                         }, "ezviz", "init", [accessToken,telNo]);
        },
        listCamera:function(successCallback,errorCallback){
            cordova.exec(function(){}, function(error){
                console.log('list camera error:',error);
            }, "ezviz", "listCamera", []);
        },
            preview:function(deviceSerial,cameraIndex,successCallback,errorCallback){
                cordova.exec(function(){}, function(error){
                                                           console.log('list camera error:',error);
                                                       }, "ezviz", "preview", [deviceSerial,cameraIndex || 0,"开门","openDoorABCD"]);
            }
};


