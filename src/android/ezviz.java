package com.laitron.ezviz;

import android.content.Intent;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;

import com.videogo.constant.IntentConsts;
import com.videogo.errorlayer.ErrorInfo;
import com.videogo.exception.BaseException;
import com.videogo.exception.InnerException;
import com.videogo.openapi.bean.EZCameraInfo;
import com.videogo.ui.cameralist.EZCameraListActivity;
import com.videogo.ui.realplay.EZRealPlayActivity;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.ui.util.EZUtils;
import com.videogo.openapi.bean.EZDeviceInfo;
import com.videogo.util.LogUtil;


import android.content.IntentFilter;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
public class ezviz extends CordovaPlugin {
    public static String AppKey = "ec8223fe65fc42be8e142ecf0c721139";
    public String accessToken = "";
    public String telNo = "";


    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {

        if (action.equals("greet")) {

            String name = data.getString(0);
            String message = "Hello, " + name;
            callbackContext.success(message);

            return true;

        } else if(action.equals("listCamera")){
            Intent toIntent = new Intent(cordova.getActivity(), EZCameraListActivity.class);
            toIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            cordova.getActivity().startActivity(toIntent);
            callbackContext.success("");

            return true;
        }else if(action.equals("preview")){
            String deviceSerial = data.getString(0);
            int camera_index = data.getInt(1) ;
            try{
                EZDeviceInfo deviceInfo = EZOpenSDK.getInstance().getDeviceInfo( deviceSerial);
                Intent toIntent = new Intent(cordova.getActivity(), EZRealPlayActivity.class);
                EZCameraInfo cameraInfo = null;
                cameraInfo = EZUtils.getCameraInfoFromDevice(deviceInfo, camera_index);

                if (cameraInfo == null) {
                    callbackContext.error("没有找到摄像头信息");
                    return false;
                }else{
                    toIntent.putExtra(IntentConsts.EXTRA_CAMERA_INFO, cameraInfo);
                    toIntent.putExtra(IntentConsts.EXTRA_DEVICE_INFO, deviceInfo);
                    String caption,eventName;
                    //应该用bundle的，不改了
                    if(data.length() >= 3){

                        caption = data.getString(2);


                    }else{
                        caption = "";
                    }

                    if(data.length() >= 4) {

                        eventName = data.getString(3);

                    }else{
                        eventName = "";
                    }


                    Bundle extraInfo = new Bundle();
                    extraInfo.putParcelable(IntentConsts.EXTRA_CAMERA_INFO,cameraInfo);
                    extraInfo.putParcelable(IntentConsts.EXTRA_DEVICE_INFO,deviceInfo);
                    extraInfo.putString("com.laitron.ezviz.action_on_preview",caption);
                    extraInfo.putString("com.laitron.ezviz.evt_on_preview",eventName);
                    toIntent.putExtras(extraInfo);
                    cordova.getActivity().startActivityForResult(toIntent, 100);
                    //toIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    // cordova.getActivity().startActivity(toIntent);
                    callbackContext.success("");

                    return true;
                }
            } catch (BaseException e) {
                e.printStackTrace();

                ErrorInfo errorInfo = (ErrorInfo) e.getObject();

                LogUtil.debugLog("ezviz", errorInfo.toString());
                callbackContext.error(errorInfo.toString());
                return false;
            }

        }else if(action.equals("init")){
            accessToken=data.getString(0);
            telNo = data.getString(1);
            EZOpenSDK.getInstance().setAccessToken(accessToken);
            callbackContext.success("");

            return true;
        }else {
            
            return false;

        }
    }

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);


        // your init code here
        initSDK();
    }
    private void initSDK() {


            /**
             * sdk日志开关，正式发布需要去掉
             */
            EZOpenSDK.showSDKLog(true);

            /**
             * 设置是否支持P2P取流,详见api
             */
            EZOpenSDK.enableP2P(true);

            /**
             * APP_KEY请替换成自己申请的
             */
            EZOpenSDK.initLib(this.cordova.getActivity().getApplication(), AppKey, "");

    }
    public void showCameraList(){

    }

    public void showReplay(String deviceSerial){

    }



}
