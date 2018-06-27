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
    FTRConfig *ftrConfig = [FTRConfig configWithApiKey:@"YOUR_API_KEY" withBaseUrl:@"https://api.futurae.com:443"];
    [FuturaeClient launchWithConfig:ftrConfig inApplication:application];
    
    
    // push notifications
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) { // iOS 10+
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // NOTE: To be completed
                              }];
    } else { // iOS 8+ without UserNotifications Framework
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

#pragma mark - Handle Push Notifications
////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[FuturaeClient sharedClient] registerPushToken:deviceToken];
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
    // TODO: Handle this case
    NSLog(@"Received APN: %@", userInfo);
}

////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // TODO: Fetch data from backend and call completionHandler
    NSLog(@"Received APN with completionHandler: %@", userInfo);
    
    [[FuturaeClient sharedClient] handleNotification:userInfo delegate:self];
    [self showLocalNotification:@"Authentication Request" withBody:userInfo[@"body"]];
}

////////////////////////////////////////////////////////////////////////////////
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"Received local notification: %@", notification);
}

#pragma mark - Handle URL Scheme calls
////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Received URL Scheme call from %@: %@", sourceApplication, url);
    
    // TODO: Check if you want to open this URL and then pass it to the FuturaeClient as shown below
    [[FuturaeClient sharedClient] openURL:url sourceApplication:sourceApplication annotation:annotation delegate:self];
    
    return YES;
}

#pragma mark - UserNotifications delegate
////////////////////////////////////////////////////////////////////////////////
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    // FIXME: To be completed
    NSLog(@"userNotificationCenter willPresentNotification");
}

////////////////////////////////////////////////////////////////////////////////
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler
{
    // FIXME: To be completed
    NSLog(@"userNotificationCenter didReceiveNotificationResponse");
}

#pragma mark - FTRNotificationDelegate
////////////////////////////////////////////////////////////////////////////////
- (void)approveAuthenticationReceived:(nonnull NSDictionary *)authenticationInfo
{
    // TODO: Retrieve more details regarding the authentication attempt from the backend
    // For demo purposes we just show an alert to approve / reject the authentication request
    
    NSLog(@"Received approve authentication: %@", authenticationInfo);
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Approve"
                                                                message:@"Would you like to approve the request?"
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Approve" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[FuturaeClient sharedClient] approveAuthWithUserId:authenticationInfo[@"user_id"] sessionId:authenticationInfo[@"session_id"] callback:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Failed to approve: %@", error);
                return;
            }
        }];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Deny" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[FuturaeClient sharedClient] rejectAuthWithUserId:authenticationInfo[@"user_id"] sessionId:authenticationInfo[@"session_id"] isFraud:NO callback:^(NSError * _Nullable error) {
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
    
    // For demo purposes we automatically confirm it and then only ask the user wants to switch back to the caller
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"MobileAuth Success"
                                                                message:@"Would you like to open the callback?"
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:authenticationInfo[@"success_url_callback"]];
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:nil];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"");
    }]];
    [self.window.rootViewController presentViewController:ac animated:NO completion:nil];
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
    // TODO: Handle the error
    NSLog(@"openURLError: %@", error);
    [self _showAlertWithTitle:@"Error" message:@"Enrollment failed"];
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
