/*global cordova, module*/

module.exports = {
    /*
    * 萤石sdk初始化
    * params: accessToken 用户的唯一凭证
    */
    init:function(accessToken, successCallback, errorCallback){
        cordova.exec(
            successCallback,
            errorCallback, 
            "ezviz", 
            "init", 
            [accessToken || '']
        );
    },
    /*
    * 打开摄像头设备列表
    * params: 
    */
    listCamera:function(successCallback,errorCallback){
        cordova.exec(successCallback, errorCallback, "ezviz", "listCamera", []);
    },
    /*
    * 打开摄像头播放页面
    * params: 
    *   accessToken 用户的唯一凭证
    *   deviceSerial 摄像头序列号
    *   cameraIndex 设备标识
    *   eventName 触发事件的事件名
    *   doorCaption 开门动作
    *   lightCaption 开灯动作
    */
    preview:function(accessToken,deviceSerial,cameraIndex,eventName,doorCaption,lightCaption,successCallback,errorCallback){
        cordova.exec(
            successCallback || function(){},
            errorCallback || function(error){ 
                console.log('open camera error:',error);
            },
            "ezviz",
            "preview",
            [
                accessToken||"",
                deviceSerial,
                cameraIndex || 0,
                eventName || "",
                doorCaption || "",
                lightCaption || ""
            ]
        );
    },
    /*
    * 打开添加摄像头页面
    * params: 
    *   accessToken 用户的唯一凭证
    */
    openAddDevice: function (accessToken, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "ezviz", "openAddDevice", [accessToken || ""]);
    },
    /*
    * 删除摄像头设备
    * params: 
    *   accessToken 用户的唯一凭证
    *   deviceSerial 摄像头序列号
    */
    deleteDevice: function (accessToken, deviceSerial, successCallback, errorCallback) {
        cordova.exec(
            successCallback, 
            errorCallback, 
            "ezviz", 
            "deleteDevice",
            [accessToken || "", deviceSerial || ""]
        );
    }
};
