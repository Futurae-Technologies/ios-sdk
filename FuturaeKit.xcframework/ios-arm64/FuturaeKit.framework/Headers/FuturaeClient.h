//
//  FuturaeClient.h
//  FuturaeKit
//
//  Created by Dimitris Togias on 27/12/2017.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2018 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <FuturaeKit/FTRNotificationDelegate.h>
#import <FuturaeKit/FTROpenURLDelegate.h>

// The domain for all errors originating in FuturaeClient.
FOUNDATION_EXPORT NSString * _Nonnull const FuturaeClientErrorDomain;

// error codes
FOUNDATION_EXTERN const NSUInteger FuturaeClientErrorGeneric;
FOUNDATION_EXTERN const NSUInteger FuturaeClientErrorInvalidEnrollmentCode;
FOUNDATION_EXTERN const NSUInteger FuturaeClientErrorInvalidAuthorizationCode;
FOUNDATION_EXTERN const NSUInteger FuturaeClientErrorAccountAlreadyActive;
FOUNDATION_EXTERN const NSUInteger FuturaeClientErrorOutdatedApp;

// notifications
FOUNDATION_EXTERN _Nonnull NSNotificationName const FuturaeNotificationError;
FOUNDATION_EXTERN _Nonnull NSNotificationName const FuturaeNotificationUnEnroll;
FOUNDATION_EXTERN _Nonnull NSNotificationName const FuturaeNotificationApprove;

@class FTRTotp;
@class FTRConfig;
@class FTRKitHTTPSessionManager;

typedef void (^FTRRequestHandler)(NSError * _Nullable error);
typedef void (^FTRRequestDataHandler)(id _Nullable data);

__attribute__((deprecated(("Use FTRClient instead."))))
@interface FuturaeClient : NSObject
{
    FTRKitHTTPSessionManager *_sessionManager;
    NSDateFormatter *_rfc2882DateFormatter;
}

+ (NSString * _Nonnull)version;
+ (nullable instancetype)sharedClient;
+ (void)launchWithConfig:(FTRConfig * _Nonnull)config;
+ (void)launchWithConfig:(FTRConfig * _Nonnull)config
           inApplication:(UIApplication * _Nonnull)application __attribute__((deprecated("Use launchWithConfig: method instead.")));
+ (void)launchWith:(NSArray * _Nullable)kitClasses
            config:(FTRConfig * _Nonnull)config
     inApplication:(UIApplication * _Nonnull)application __attribute__((deprecated("Use launchWithConfig: method instead.")));

// public

// Lifecycle

- (void)clearDataFromDB:(BOOL)fromDB
           fromKeychain:(BOOL)fromKeychain;

// Database
- (NSArray * _Nonnull)getAccounts;
- (NSDictionary * _Nonnull)getAccountByUserId:(NSString * _Nonnull)userId;

// URI Scheme handling
- (BOOL)openURL:(nullable NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> * _Nonnull)options
       delegate:(nullable id<FTROpenURLDelegate>)delegate;

// Push Notifications
- (void)registerPushToken:(NSData * _Nonnull)deviceToken;
- (void)handleNotification:(NSDictionary * _Nonnull)payload
                  delegate:(nullable id<FTRNotificationDelegate>)delegate;

// User enrollment/logout
- (void)enroll:(NSString * _Nonnull)qrCode
      callback:(nullable FTRRequestHandler)callback;
- (void)logoutUser:(NSString * _Nonnull)userId
          callback:(nullable FTRRequestHandler)callback;
- (void)logoutAccount:(nonnull NSDictionary *)account
             callback:(nullable FTRRequestHandler)callback;

// Accounts status
- (void)getAccountsStatus:(NSArray * _Nonnull)accounts
                  success:(nullable FTRRequestDataHandler)success
                  failure:(nullable FTRRequestHandler)failure;

// User authentication
- (void)getSessionInfo:(NSString * _Nonnull)userId
             sessionId:(NSString * _Nonnull)sessionId
               success:(nullable FTRRequestDataHandler)success
               failure:(nullable FTRRequestHandler)failure;
- (void)getSessionInfo:(NSString * _Nonnull)userId
          sessionToken:(NSString * _Nonnull)sessionToken
               success:(nullable FTRRequestDataHandler)success
               failure:(nullable FTRRequestHandler)failure;

- (void)approveAuthWithQrCode:(NSString * _Nonnull)qrCode
                    extraInfo:(NSArray * _Nullable)extraInfo
                     callback:(nullable FTRRequestHandler)callback;
- (void)approveAuthWithUserId:(NSString * _Nonnull)userId
                    sessionId:(NSString * _Nonnull)sessionId
                    extraInfo:(NSArray * _Nullable)extraInfo
                     callback:(nullable FTRRequestHandler)callback;
- (void)rejectAuthWithUserId:(NSString * _Nonnull)userId
                   sessionId:(NSString * _Nonnull)sessionId
                     isFraud:(Boolean)isFraud
                   extraInfo:(NSArray * _Nullable)extraInfo
                    callback:(nullable FTRRequestHandler)callback;

- (void)approveAuthWithQrCode:(NSString * _Nonnull)qrCode
                     callback:(nullable FTRRequestHandler)callback;
- (void)approveAuthWithUserId:(NSString * _Nonnull)userId
                    sessionId:(NSString * _Nonnull)sessionId
                     callback:(nullable FTRRequestHandler)callback;
- (void)rejectAuthWithUserId:(NSString * _Nonnull)userId
                   sessionId:(NSString * _Nonnull)sessionId
                     isFraud:(Boolean)isFraud
                    callback:(nullable FTRRequestHandler)callback;

// User offline authentication
- (FTRTotp * _Nonnull)nextTotpForUser:(NSString * _Nonnull)userId;

@end
