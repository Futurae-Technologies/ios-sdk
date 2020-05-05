## Summary

This is the iOS SDK of Futurae. You can read more about Futurae™ at [futurae.com].

## Table of contents

* [Basic integration](#basic-integration)
   * [Get FuturaeKit SDK for iOS](#get-futuraekit-sdk-for-ios)
   * [Add SDK to Project](#add-sdk-to-project)
   * [Integrate SDK into your app](#integrate-sdk-into-your-app)
   * [Basic setup](#basic-setup)
   * [Build your app](#build-your-app)
   * [Clear SDK data](#clear-sdk-data)
* [Features](#features)
   * [URI Schemes](#uri-schemes)
   * [Push Notifications](#push-notifications)
   * [Enroll User](#enroll-user)
   * [Logout User](#logout-user)
   * [Account Status](#account-status)
   * [Authenticate User](#authenticate-user)
      * [QR Code Factor](#qr-code-factor)
      * [Push Notification Factor](#push-notification-factor)
	       * [Approve Authentication](#approve-authentication)
	       * [Reject Authentication](#reject-authentication)
      * [TOTP Factor](#totp-factor)
      * [Session Information](#session-information)


## <a id="basic-ntegration" />Basic integration

We will describe the steps to integrate the FuturaeKit SDK into your iOS project. We are going to assume that you are using Xcode for your iOS development.

### <a id="get-futuraekit-sdk-for-ios" />Get FuturaeKit SDK for iOS

You can download the latest SDK from the [releases](https://git.futurae.com/futurae-public/futurae-ios-sdk/tags) page, or clone this repository directly. This repository also contains a simple demo app to show how the SDK can be integrated.

### <a id="add-sdk-to-project" />Add SDK to Project

You can include the FuturaeKit SDK by adding the `FuturaeKit.framework` manually to your targets *Embedded Binaries* (in the General tab). Afterwards, drag the `FuturaeKit.framework` into the `Frameworks` group of your project.

![][sdk]

### <a id="integrate-sdk-into-your-app" />Integrate SDK into your app

FuturaeKit SDK is a dynamic framework, so you should use the following import statement:

```objc
#import <FuturaeKit/FuturaeKit.h>
```

Next, we'll set up basic functionality.

### <a id="basic-setup" />Basic setup

In the Project Navigator, open the source file of your application delegate. Add the `import` statement at the top of the file, then add the following call to `FuturaeKit` in the `didFinishLaunching` or `didFinishLaunchingWithOptions` method of your app delegate:

```objc
#import <FuturaeKit/FuturaeKit.h>

// ...
FTRConfig *ftrConfig = [FTRConfig configWithSdkId:@"{FuturaeSdkId}" sdkKey:@"{FuturaeSdkKey}" baseUrl:@"https://api.futurae.com:443"];
[FuturaeClient launchWithConfig:ftrConfig inApplication:application];
```

**Note**: Initializing the FuturaeKit SDK like this is `very important`. Replace `{FuturaeSdkId}` and `{FuturaeSdkKey}` with your SDK ID and key.
If needed, you can also change the base host of the Futurae API.

### <a id="build-your-app" />Build your app

Build and run your app. If the build succeeds, you should carefully read the SDK logs in the console.

### <a id="clear-sdk-data" />Clear SDK data

Futurae iOS SDK provides a convenient method to clear all SDK internal data:

```objc
#import <FuturaeKit/FuturaeKit.h>

[[FuturaeClient sharedClient] clearDataFromDB:YES fromKeychain:NO];
```

This method removes the following data:

- Internal DB (`fromDB` must be set to `YES`)
- Internal SDK keychain material, including cryptographic keys and identifiers (`fromKeychain` must be set to `YES`)

Clearing the SDK data brings it to a fresh-start state. Hence, you can enroll new users and make use of it as per usual.

## <a id="features" />Features

### <a id="uri-schemes" />URI Schemes

To handle the Futurae URI scheme calls, implement the `FTROpenURLDelegate` and add the following call in the `openURL:sourceApplication:annotation:` method of your app delegate:

```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
		[[FuturaeClient sharedClient] openURL:url sourceApplication:sourceApplication annotation:annotation delegate:self];

		return YES;
}
```

### <a id="push-notifications" />Push Notifications

To enable push notifications add the following call in the `didFinishLaunching` or `didFinishLaunchingWithOptions` method of your app delegate:

```objc
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
```

To send the push notification token, add the following call in the `didRegisterForRemoteNotificationsWithDeviceToken` method of your app delegate:

```objc
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    [[FuturaeClient sharedClient] registerPushToken:deviceToken];
}
```

To handle the Futurae push notifications, implement the `FTRNotificationDelegate` and add the following call in the respective method of your app delegate (`didReceiveRemoteNotification:fetchCompletionHandler:` or `pushRegistry:didReceiveIncomingPushWithPayload:`):

```objc
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type
{
    [[FuturaeClient sharedClient] handleNotification:payload delegate:self];
}
```

### <a id="enroll-user" />Enroll User

To enroll a user, you must call the following method, using a valid code:
```objc
[[FuturaeClient sharedClient] enroll:code callback:^(NSError *error) {

}];
```

You can either call directly the above method or use a QR-Code Reader UIViewController to scan a code:

```objc
FTRQRCodeViewController *qrcodeVC = [[FTRQRCodeViewController alloc] init];
qrcodeVC.delegate = self;
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:qrcodeVC];
[self presentViewController:navigationController animated:YES completion:nil];
```

If a QR-Code is successfully scanned then the following delegate method with be called, with the scanned code:

```objc
- (void)reader:(FTRQRCodeViewController * _Nullable)reader didScanResult:(NSString *_Nullable)result
{
  ...
}
```

Please make sure to call enroll, inside the delegate method to complete the user enrollment:
```objc
[[FuturaeClient sharedClient] enroll:result callback:^(NSError *error) {

}];
```

### <a id="logout-user" />Logout User

To logout a user, you must call the following method:

```objc
[[FuturaeClient sharedClient] logoutForUser:userId callback:^(NSError *error) {

}];
```

### <a id="account-status" />Account Status

To get a list of all enrolled accounts, call the following method:

```objc
NSArray *accounts = [[FuturaeClient sharedClient] getAccounts];
```

To fetch the status and current sessions for these accounts, you can use the following method:

```objc
[[FuturaeClient sharedClient] getAccountsStatus:accounts
                                        success:^(id _Nullable data) {
                                            // Handle the pending sessions
                                        }
                                        failure:^(NSError * _Nullable error) {
                                            // Handle the error
                                        }];
```

**Hint:** You can use this method if you want to check if there are any pending sessions, e.g. when the app wakes up or the user refreshes the view.
For each account, a list of active sessions will be returned, and each session includes a `session ID` to proceed with the authentication.

### <a id="authenticate-user" />Authenticate User

To authenticate (or reject) a user session, depending on the authentication factor, you can use the following methods:

#### <a id="qr-code-factor" />QR Code Factor

Get the result of the QR Code scan and feed it to the following method:

```objc
[[FuturaeClient sharedClient] approveAuthWithQrCode:qrCodeScanResult
                                           callback:^(NSError * _Nullable error) {

}];
```

Get the result of the QR Code scan with `extraInfo` field and feed it to the following method:

```objc
[[FuturaeClient sharedClient] approveAuthWithQrCode:qrCodeScanResult
                                          extraInfo:extraInfo
                                           callback:^(NSError * _Nullable error) {

}];
```

#### <a id="push-notification-factor" />Push Notification Factor

Get the `user ID` and `session ID` from the Push Notification handler and feed them to one of the following methods:

##### <a id="approve-authentication" />Approve Authentication

To approve a user authentication:

```objc
[[FuturaeClient sharedClient] approveAuthWithUserId:userId
                                          sessionId:sessionId
                                           callback:^(NSError * _Nullable error) {

}];
```

To approve a user authentication when `extraInfo` field has a `non-null` value:

```objc
[[FuturaeClient sharedClient] approveAuthWithUserId:userId
                                          sessionId:sessionId
                                          extraInfo:extraInfo
                                           callback:^(NSError * _Nullable error) {

}];
```

##### <a id="reject-authentication" />Reject Authentication

To reject a user authentication (and optionally define it as `fraud`):

```objc
[[FuturaeClient sharedClient] rejectAuthWithUserId:userId sessionId:sessionId
                                                            isFraud:@(NO)
                                                           callback:^(NSError * _Nullable error) {

}];
```

To reject a user authentication when `extraInfo` field has a `non-null` value (and optionally define it as `fraud`):

```objc
[[FuturaeClient sharedClient] rejectAuthWithUserId:userId sessionId:sessionId
                                                            isFraud:@(NO)
                                                          extraInfo:extraInfo
                                                           callback:^(NSError * _Nullable error) {

}];
```

#### <a id="totp-factor" />TOTP Factor

In order for the user to authenticate using the offline TOTP factor, you need to show the current TOTP to the user. You can get the later by calling:

```objc
NSDictionary *result = [[FuturaeClient sharedClient] nextTotpForUser:userId];
```

The `result` dictionary contains the current 6-digit TOTP and the remaining seconds that it will be valid for:

```objc
@{@"totp": @"444123", @"remaining_secs":@(26)}
```

#### <a id="session-information" />Session Information
For a given session, either identified via a `session ID` (e.g. received by a push notification) or a `session Token` (e.g. received by a QRCode scan), you can ask the server for more information about the session:

```objc
// if you have a session ID
- (void)getSessionInfo:(NSString * _Nonnull)userId
             sessionId:(NSString * _Nonnull)sessionId
               success:(nullable FTRRequestDataHandler)success
               failure:(nullable FTRRequestHandler)failure;

// if you have a session Token
- (void)getSessionInfo:(NSString * _Nonnull)userId
          sessionToken:(NSString * _Nonnull)sessionToken
               success:(nullable FTRRequestDataHandler)success
               failure:(nullable FTRRequestHandler)failure;
```

If there is extra information to be displayed to the user, for example when confirming a transaction, this will be indicated with a list of key-value pairs in the `extra_info` part of the response.


[futurae.com]:  http://www.futurae.com

[sdk]:        ./Resources/sdk.png
