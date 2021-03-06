//
//  AppDelegate.m
//  jisudai
//
//  Created by haodai on 16/3/14.
//  Copyright © 2016年 xiaoya. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import <BmobSDK/Bmob.h>
#import "WXApi.h"
#import "GuideView.h"

@interface AppDelegate ()<WXApiDelegate>
@property (nonatomic, strong)  GuideView *guideView;
@end

@implementation AppDelegate

//
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [MobClick startWithAppkey:YouMeng_Key reportPolicy:SEND_INTERVAL   channelId:@"AppStore"];
    [Bmob  registerWithAppKey:BmobApplicationID];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc]init];
        //注意：此处的Bundle ID要与你申请证书时填写的一致。
        categorys.identifier = APP_BundleID;
        UIUserNotificationSettings *userNotifiSetting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:[NSSet setWithObjects:categorys,nil]];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifiSetting];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else {
        //注册远程推送
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    [WXApi registerApp:WEIXING_KEY];
    [LoansSDK loadPPDLoanInit:PAIPAIDAIKEY];
    [self.window makeKeyAndVisible];
    if (mIsiphone) {
//      引导页
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"] isEqualToString:currentVersion]) {
            [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"firstLaunch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self firstLaunch];
        }
    }
    return YES;
}

#pragma mark -
- (void)firstLaunch {
    if (_guideView == nil) {
        _guideView = [[GuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_guideView.backButton addTarget:self action:@selector(didSelectedStartButton) forControlEvents:UIControlEventTouchUpInside];
        [self.window addSubview:_guideView];
    }
}

- (void)didSelectedStartButton {
    [UIView animateWithDuration:2  animations:^{
        _guideView.alpha = 0;
    } completion:^(BOOL finished) {
        [_guideView removeFromSuperview];
        _guideView = nil;
    }];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    //注册成功后上传Token至服务器
    BmobInstallation  *currentIntallation = [BmobInstallation currentInstallation];
    [currentIntallation setDeviceTokenFromData:deviceToken];
    [currentIntallation saveInBackground];
}

@end
