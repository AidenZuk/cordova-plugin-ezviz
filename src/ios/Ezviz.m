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
    [EZOpenSDK setDebugLogEnable:NO];
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

    //添加设备添加完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completionButtonClicked:) name:@"completionButtonClicked" object:nil];
}

- (void)greet:(CDVInvokedUrlCommand*)command
{
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];

    [self execCallback:msg status:CDVCommandStatus_OK command:command];
}

- (void) listCamera:(CDVInvokedUrlCommand*)command
{
    UIStoryboard *EZMain = [self getStoryboard:@"EZMain"];
    if (EZMain) {
        EZCameraTableViewController *ezCamera = [EZMain instantiateViewControllerWithIdentifier:@"EZCameraTableViewController"];
        [self.viewController.navigationController pushViewController:ezCamera animated:true];
        [self execCallback:@"success" status:CDVCommandStatus_OK command:command];
        return;
    }
    [self execCallback:@"UIStoryboard EZMain is nil" status:CDVCommandStatus_ERROR command:command];
}

- (void) preview:(CDVInvokedUrlCommand*)command
{
    NSArray* data = [command arguments];
    NSString* accessToken = [data objectAtIndex:0];
    NSString* deviceSerial = [data objectAtIndex:1];
    NSString* camera_index = [data objectAtIndex:2];

    [[NSUserDefaults standardUserDefaults] setObject:accessToken?:@"" forKey:@"EZOpenSDKAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if(![accessToken  isEqual: @""]) {
        [EZOpenSDK setAccessToken:accessToken];
        [EZOpenSDK getDeviceInfo:deviceSerial completion: ^(EZDeviceInfo *deviceInfo, NSError *error) {
            if (error == NULL) {
                UIStoryboard *EZMain = [self getStoryboard:@"EZMain"];
                if (EZMain) {
                    EZLivePlayViewController *livePlay = [EZMain instantiateViewControllerWithIdentifier:@"EZLivePlayViewController"];
                    livePlay.delegate = self;
                    livePlay.deviceInfo = deviceInfo;
                    livePlay.cameraIndex = [camera_index intValue];
                    livePlay.eventName = [self contrastResult:(data.count >= 4) firstValue:[data objectAtIndex:3] secondValue:@""];
                    livePlay.caption = [self contrastResult:(data.count >= 5) firstValue:[data objectAtIndex:4] secondValue:@""];
                    livePlay.lightCaption = [self contrastResult:(data.count >= 6) firstValue:[data objectAtIndex:5] secondValue:@""];

                    [self.viewController.navigationController pushViewController:livePlay animated:true];
                    [self execCallback:@"success" status:CDVCommandStatus_OK command:command];
                    return;
                }
                [self execCallback:@"UIStoryboard EZMain is nil" status:CDVCommandStatus_ERROR command:command];
            }else{
                [self execCallback:@"no camera info" status:CDVCommandStatus_ERROR command:command];
            }
        }];
    }
}

- (void) init:(CDVInvokedUrlCommand*)command
{
    NSString* accessToken = [[command arguments] objectAtIndex:0];
    [EZOpenSDK setAccessToken:accessToken];

    [self execCallback:@"success" status:CDVCommandStatus_OK command:command];
}

- (void) openAddDevice:(CDVInvokedUrlCommand*)command
{
    NSArray* data = [command arguments];
    NSString* accessToken = [data objectAtIndex:0];

    [EZOpenSDK setAccessToken:accessToken];

    UIStoryboard *AddDevice = [self getStoryboard:@"AddDevice"];
    if (AddDevice) {
        EZAddByQRCodeViewController *addByQRCode = [AddDevice instantiateViewControllerWithIdentifier:@"AddByQRCode"];
        UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] init];
        returnButton.title = @"";
        self.viewController.navigationItem.backBarButtonItem = returnButton;
        [self.viewController.navigationController pushViewController:addByQRCode animated:true];
        [self execCallback:@"success" status:CDVCommandStatus_OK command:command];
        return;
    }
    [self execCallback:@"UIStoryboard AddDevice is nil" status:CDVCommandStatus_ERROR command:command];
}

- (void) deleteDevice:(CDVInvokedUrlCommand*)command
{
    NSArray* data = [command arguments];
    NSString* accessToken = [data objectAtIndex:0];
    NSString* deviceSerial = [data objectAtIndex:1];

    [EZOpenSDK setAccessToken:accessToken];

    [EZOpenSDK deleteDevice:deviceSerial completion:^(NSError *error) {
        NSLog(@"error is %@",error);
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteDevice" object:nil userInfo:@{@"code": @(0)}];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteDevice" object:nil userInfo:@{@"code": @(error.code)}];
        }
        [self execCallback:@"success" status:CDVCommandStatus_OK command:command];
    }];
    [self execCallback:@"success" status:CDVCommandStatus_OK command:command];
}

- (NSString *) contrastResult:(BOOL)condition firstValue:(NSString *)firstValue secondValue: (NSString *)secondValue
{
    if (condition) {
        return firstValue;
    }else {
        return secondValue;
    }
}

- (UIStoryboard *) getStoryboard: (NSString *)name
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
    if (storyboard) {
        return storyboard;
    }
    return nil;
}

- (void) execCallback:(NSString *)msg status:(CDVCommandStatus)status command:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:status
                               messageAsString:msg];

    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
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

/* NSNotification */
- (void)completionButtonClicked: (NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString *deviceSerialNo = [userInfo valueForKey:@"deviceSerialNo"];
    [EZOpenSDK getDeviceInfo:deviceSerialNo completion:^(EZDeviceInfo *deviceInfo, NSError *error) {
        if (deviceInfo) {
            EZCameraInfo *cameraInfo = deviceInfo.cameraInfo[0];
            NSString *videoLevel = [NSString stringWithFormat:@"%ld", (long)cameraInfo.videoLevel];
            NSString *defence = [NSString stringWithFormat:@"%ld", (long)deviceInfo.defence];
            NSString *isEncrypt = [NSString stringWithFormat:@"%ld", (long)deviceInfo.isEncrypt];
            NSString *isShared = [NSString stringWithFormat:@"%ld", (long)cameraInfo.isShared];
            NSString *status = [NSString stringWithFormat:@"%ld", (long)deviceInfo.status];
            NSString *cameraNo = [NSString stringWithFormat:@"%ld", (long)cameraInfo.cameraNo];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"completeDevice" object:nil userInfo:@{@"data": @{@"videoLevel": videoLevel, @"defence": defence, @"isEncrypt": isEncrypt, @"picUrl": cameraInfo.cameraCover, @"isShared": isShared, @"status": status, @"cameraName": cameraInfo.cameraName, @"cameraNo": cameraNo, @"deviceName": deviceInfo.deviceName, @"deviceSerial": deviceInfo.deviceSerial}}];

            NSArray *viewControllers = self.viewController.navigationController.viewControllers;
            for (UIViewController *vc in viewControllers)
            {
                if ([vc isKindOfClass:[CDVViewController class]])
                {
                    [self.viewController.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"completeDevice" object:nil userInfo:@{@"error": @"no cameraInfo"}];
        }
    }];
}

@end
