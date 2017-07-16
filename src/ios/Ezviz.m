//
//  Ezviz.m
//  永天智家
//
//  Created by MrMessy on 2017/6/16.
//
//

#import "Ezviz.h"
#import <EZDemoSDK/EZDemoSDK.h>

@interface Ezviz()<EZLivePlayViewControllerDelegate>

@end

@implementation Ezviz

- (void)pluginInitialize
{
    [super pluginInitialize];
    //sdk日志开关，正式发布需要去掉
    //    [EZOpenSDK setDebugLogEnable:YES];
    //设置是否支持P2P取流,详见api
    [EZOpenSDK enableP2P:YES];
    //APP_KEY请替换成自己申请的
    NSArray *bundleUrltypes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    NSArray *appKey;
    for (int i = 0; i < bundleUrltypes.count; i ++) {
        NSDictionary *bundleUrltype = bundleUrltypes[i];
        if ([[bundleUrltype objectForKey:@"CFBundleURLName"]  isEqual: @"ys7_appkey"]) {
            appKey = [bundleUrltype objectForKey:@"CFBundleURLSchemes"];
        }
    }
    [EZOpenSDK initLibWithAppKey: appKey[0]];
}

- (void)greet:(CDVInvokedUrlCommand*)command
{
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];
    
    [self execCallback:msg command:command];
}

- (void) listCamera:(CDVInvokedUrlCommand*)command
{
    EZCameraTableViewController *ezCamera = [[UIStoryboard storyboardWithName:@"EZMain" bundle:[self getBundle]] instantiateViewControllerWithIdentifier:@"EZCameraTableViewController"];
    [self.viewController.navigationController pushViewController:ezCamera animated:true];
    [self execCallback:@"" command:command];
}

- (void) preview:(CDVInvokedUrlCommand*)command
{
    NSArray* data = [command arguments];
    NSString* accessToken = [data objectAtIndex:0];
    NSString* deviceSerial = [data objectAtIndex:1];
    NSString* camera_index = [data objectAtIndex:2];
    
    if(![accessToken  isEqual: @""]) {
        [EZOpenSDK setAccessToken:accessToken];
        [EZOpenSDK getDeviceInfo:deviceSerial completion: ^(EZDeviceInfo *deviceInfo, NSError *error) {
            if (error == NULL) {
                EZLivePlayViewController *livePlay = [[UIStoryboard storyboardWithName:@"EZMain" bundle:[self getBundle]] instantiateViewControllerWithIdentifier:@"EZLivePlayViewController"];
                livePlay.delegate = self;
                livePlay.deviceInfo = deviceInfo;
                livePlay.cameraIndex = [camera_index intValue];
                livePlay.eventName = (data.count >= 4) ? [data objectAtIndex:3] : @"";
                livePlay.caption = (data.count >= 5) ? [data objectAtIndex:4] : @"";
                livePlay.lightCaption = (data.count >= 6) ? [data objectAtIndex:5] : @"";
                
                [self.viewController.navigationController pushViewController:livePlay animated:true];
                [self execCallback:@"" command:command];
            }else{
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"没有找到摄像头信息"];
                [self.commandDelegate sendPluginResult:pluginResult
                                            callbackId:command.callbackId];
            }
        }];
    }
}

- (void) init:(CDVInvokedUrlCommand*)command
{
    NSString* accessToken = [[command arguments] objectAtIndex:0];
    //    NSString* telNo = [[command arguments] objectAtIndex:1];
    [EZOpenSDK setAccessToken:accessToken];
    [self execCallback:@"" command:command];
}

- (void) execCallback:(NSString *)msg command:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];
    
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
}

- (NSBundle *)getBundle {
    return [NSBundle bundleWithPath: [[NSBundle mainBundle] pathForResource:@"EZDemoSDKResources" ofType: @"bundle"]];
}

/* EZLivePlayViewControllerDelegate */
- (void)openLightPressed:(UIButton *)sender livePlayController:(EZLivePlayViewController *)livePlayController
{
    NSString *eventName = livePlayController.eventName;
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:@{@"data":@"click",@"source":@"light"}];
}

- (void)openDoorPressed:(UIButton *)sender livePlayController:(EZLivePlayViewController *)livePlayController
{
    NSString *eventName = livePlayController.eventName;
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:@{@"data":@"click",@"source":@"door"}];
}

- (void)viewWillDisappear:(EZLivePlayViewController *)livePlayController
{
    if (![livePlayController.eventName isEqual:@""]) {
        NSString *eventName = livePlayController.eventName;
        [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:@{@"data":@"close"}];
    }
}

@end
