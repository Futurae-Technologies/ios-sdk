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

#import "FTRNotificationDelegate.h"
#import "FTROpenURLDelegate.h"

// The domain for all errors originating in FTRClient.
FOUNDATION_EXPORT NSString * _Nonnull const FTRClientErrorDomain;

// error codes
FOUNDATION_EXTERN const NSUInteger FTRClientErrorGeneric;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorInvalidEnrollmentCode;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorInvalidAuthorizationCode;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorAccountAlreadyActive;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorOutdatedApp;

// notifications
FOUNDATION_EXTERN _Nonnull NSNotificationName const FTRNotificationError;
FOUNDATION_EXTERN _Nonnull NSNotificationName const FTRNotificationUnEnroll;
FOUNDATION_EXTERN _Nonnull NSNotificationName const FTRNotificationApprove;

@class FTRConfig;
@class FTRHTTPSessionManager;

typedef void (^FTRRequestHandler)(NSError * _Nullable error);
typedef void (^FTRRequestDataHandler)(id _Nullable data);

@interface FuturaeClient : NSObject
{
    FTRHTTPSessionManager *_sessionManager;
    NSDateFormatter *_rfc2882DateFormatter;
}

+ (NSString * _Nonnull)version;
+ (nullable instancetype)sharedClient;
+ (void)launchWithConfig:(FTRConfig * _Nonnull)config
           inApplication:(UIApplication * _Nonnull)application;

// public

// Database
- (NSArray * _Nonnull)getAccounts;
- (NSDictionary * _Nonnull)getAccountByUserId:(NSString * _Nonnull)userId;

// URI Scheme handling
- (BOOL)openURL:(nullable NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
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

- (void)approveAuthWithQrCode:(NSString *)qrCode
                    extraInfo:(NSArray *)extraInfo
                     callback:(nullable FTRRequestHandler)callback;
- (void)approveAuthWithUserId:(NSString *)userId
                    sessionId:(NSString *)sessionId
                    extraInfo:(NSArray *)extraInfo
                     callback:(nullable FTRRequestHandler)callback;
- (void)rejectAuthWithUserId:(NSString * _Nonnull)userId
                   sessionId:(NSString * _Nonnull)sessionId
                     isFraud:(Boolean)isFraud
                   extraInfo:(NSArray *)extraInfo
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
- (NSDictionary * _Nonnull)nextTotpForUser:(NSString * _Nonnull)userId;

@end
