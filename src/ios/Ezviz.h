//
//  Ezviz.h
//  永天智家
//
//  Created by MrMessy on 2017/6/16.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface Ezviz : CDVPlugin

- (void) init:(CDVInvokedUrlCommand*)command;
- (void) listCamera:(CDVInvokedUrlCommand*)command;
- (void) preview:(CDVInvokedUrlCommand*)command;
- (void) openAddDevice:(CDVInvokedUrlCommand*)command;
- (void) deleteDevice:(CDVInvokedUrlCommand*)command;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *telNo;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *deviceSerial;

@end
