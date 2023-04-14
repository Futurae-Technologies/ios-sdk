//
//  AppDelegate.m
//  FuturaeDemo
//
//  Created by Dimitris Togias on 27/12/2017.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2017 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import "AppDelegate.h"
#import <FuturaeKit/FuturaeKit.h>

#import <UserNotifications/UserNotifications.h>

////////////////////////////////////////////////////////////////////////////////
@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate

////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // push notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // NOTE: To be completed
    }];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

#pragma mark - Handle Push Notifications
////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //TODO: handle this when client not initialized yet
    if(FTRClient.sdkIsLaunched){
        [[FTRClient sharedClient] registerPushToken:deviceToken];
    } else {
        [[NSUserDefaults standardUserDefaults]
         setObject:deviceToken forKey:@"ftr_device_token"];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error
{
    // TODO: Handle this case
    NSLog(@"Failed to register APN: %@", error);
}

////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // TODO: Test this case
    [[FTRClient sharedClient] handleNotification:userInfo delegate:self];
    NSLog(@"Received APN: %@", userInfo);
}

////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // TODO: Fetch data from backend and call completionHandler
    NSLog(@"Received APN with completionHandler: %@", userInfo);

    [[FTRClient sharedClient] handleNotification:userInfo delegate:self];
    [self showLocalNotification:@"Authentication Request" withBody:userInfo[@"body"]];
}

////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // TODO: Handle this case if sypport for iOS < 10 is needed
    NSLog(@"Received local notification: %@", notification);
}

#pragma mark - Handle URL Scheme calls
////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    NSLog(@"Received URL Scheme call from %@: %@", sourceApplication, url);

    // TODO: Check if you want to open this URL and then pass it to the FTRClient as shown below
    [[FTRClient sharedClient] openURL:url options:options delegate:self];

    return YES;
}

#pragma mark - UserNotifications delegate
////////////////////////////////////////////////////////////////////////////////
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler NS_AVAILABLE_IOS(10.0)
{
    [[FTRClient sharedClient] handleNotification:notification.request.content.userInfo delegate:self];
    NSLog(@"userNotificationCenter willPresentNotification");
}

////////////////////////////////////////////////////////////////////////////////
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler NS_AVAILABLE_IOS(10.0)
{
    [[FTRClient sharedClient] handleNotification:response.notification.request.content.userInfo delegate:self];
    NSLog(@"userNotificationCenter didReceiveNotificationResponse");
}

#pragma mark - FTRNotificationDelegate
////////////////////////////////////////////////////////////////////////////////
- (void)approveAuthenticationReceived:(nonnull NSDictionary *)authenticationInfo
{
    NSLog(@"Received approve authentication: %@", authenticationInfo);

    // extra_info contains dynamic contextual information about this the authentication
    // supplied by your backend application when invoking /user/auth and /user/auth/transaction endpoints from Futurae's Auth API
    // At this point, this information, if it exists, has already been fetched from the server by the SDK and is available her
    NSMutableString *extraInfoMsg = [NSMutableString string];
    if (authenticationInfo[@"extra_info"] != nil) {
        [extraInfoMsg appendString:@"\n"];
        for (NSDictionary *pair in authenticationInfo[@"extra_info"]) {
            [extraInfoMsg appendString:pair[@"key"]];
            [extraInfoMsg appendString:@"\n"];
            [extraInfoMsg appendString:pair[@"value"]];
            [extraInfoMsg appendString:@"\n"];
        }
    }
    NSNumber *sessionTimeout = authenticationInfo[@"session_timeout"];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Approve"
                                                                message:[NSString stringWithFormat: @"Would you like to approve the request? %@. \nSession timeout:\n %@ seconds.", extraInfoMsg, sessionTimeout.stringValue]
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Approve" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[FTRClient sharedClient] approveAuthWithUserId:authenticationInfo[@"user_id"] sessionId:authenticationInfo[@"session_id"] extraInfo:authenticationInfo[@"extra_info"] callback:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Failed to approve: %@", error);
                return;
            }
        }];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Deny" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[FTRClient sharedClient] rejectAuthWithUserId:authenticationInfo[@"user_id"] sessionId:authenticationInfo[@"session_id"] isFraud:NO extraInfo:authenticationInfo[@"extra_info"]  callback:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Failed to reject: %@", error);
                return;
            }
        }];
    }]];
    [self.window.rootViewController presentViewController:ac animated:NO completion:nil];
}

////////////////////////////////////////////////////////////////////////////////
- (void)unenrollUserReceived:(nonnull NSDictionary *)accountInfo
{
    NSLog(@"unenrollUserReceived");
}

////////////////////////////////////////////////////////////////////////////////
- (void)notificationError:(nonnull NSError *)error
{
    NSLog(@"notificationError");
}

#pragma mark - Local Notifications
////////////////////////////////////////////////////////////////////////////////
- (void)showLocalNotification:(NSString *)title withBody:(NSString *)body
{
    NSDictionary *userInfo;
    UNNotificationRequest* request = [self createNotificationRequestWithBody:body
                                                                       title:title
                                                                       sound:@"default"
                                                                    category:@"FTCATEGORY_APPROVE"
                                                                    userInfo:userInfo];
    UNUserNotificationCenter *nscenter = [UNUserNotificationCenter currentNotificationCenter];
    [nscenter addNotificationRequest:request withCompletionHandler:nil];
}

////////////////////////////////////////////////////////////////////////////////
- (UNNotificationRequest *)createNotificationRequestWithBody:(NSString *)body
                                                       title:(NSString *)title
                                                       sound:(NSString *)soundName
                                                    category:(NSString *)category
                                                    userInfo:(NSDictionary *)userInfo NS_AVAILABLE_IOS(10.0)
{
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.body = body;

    if (category && ![category isEqualToString:@""]) {
        content.categoryIdentifier = category;
    }

    if (userInfo) {
        content.userInfo = userInfo;
    }

    if (soundName && ![soundName isEqualToString:@""]) {
        content.sound = [UNNotificationSound soundNamed:soundName];
    }

    return [UNNotificationRequest requestWithIdentifier:@"Futurae" content:content trigger:nil];
}

#pragma mark - FTROpenURLDelegate
////////////////////////////////////////////////////////////////////////////////
- (void)authenticationURLOpened:(nonnull NSDictionary *)authenticationInfo
{
    // TODO: Handle the successful MobileAuth request
    NSLog(@"authenticationURLOpened: %@", authenticationInfo);
    
    NSString *redirectUri = authenticationInfo[@"success_url_callback"];
    if(redirectUri && redirectUri.length > 0){
        // For demo purposes we automatically confirm it and then only ask the user wants to switch back to the caller
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"MobileAuth Success"
                                                                    message:@"Would you like to open the callback?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:redirectUri];
            [[UIApplication sharedApplication] openURL:url
                                               options:@{}
                                     completionHandler:nil];
        }]];
        [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"");
        }]];
        [self.window.rootViewController presentViewController:ac animated:NO completion:nil];
    } else {
        // For demo purposes we automatically confirm it and then only ask the user wants to switch back to the caller
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"MobileAuth Success"
                                                                    message:@""
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self.window.rootViewController presentViewController:ac animated:NO completion:nil];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)activationURLOpened:(nonnull NSDictionary *)activationInfo
{
    // TODO: Handle the successful enrollment
    NSLog(@"activationURLOpened: %@", activationInfo);
    [self _showAlertWithTitle:@"Success" message:@"Successfully enrolled"];

}

////////////////////////////////////////////////////////////////////////////////
- (void)openURLError:(nonnull NSError *)error
{
    NSString *message;
    if(error.userInfo){
        message = error.userInfo[@"msg"];
    }
    
    if(!message){
        message = error.localizedDescription;
    }
    
    if(!message){
        message = @"Unknown error";
    }
    
    // TODO: Handle the error
    NSLog(@"openURLError: %@", error);
    [self _showAlertWithTitle:@"Error" message:message];
}

#pragma mark - Alerts
////////////////////////////////////////////////////////////////////////////////
- (void)_showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self.window.rootViewController presentViewController:ac animated:YES completion:nil];
}

@end
