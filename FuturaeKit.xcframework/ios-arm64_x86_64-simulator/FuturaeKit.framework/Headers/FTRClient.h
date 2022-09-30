//
//  FTRClient.h
//  FuturaeKit
//
//  Created by Claudio Marforio on 08/07/2020.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2020 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <FuturaeKit/FTRNotificationDelegate.h>
#import <FuturaeKit/FTROpenURLDelegate.h>
#import <FuturaeKit/FTRAccount.h>
#import <FuturaeKit/LockConfiguration.h>
#import "SDKState.h"

// The domain for all errors originating in FTRClient.
FOUNDATION_EXPORT NSString * _Nonnull const FTRClientErrorDomain;
FOUNDATION_EXPORT NSString * _Nonnull const FTRClientErrorUserInfoKey;

typedef NS_ENUM(NSUInteger, FTRClientOfflineQRCodeError) {
    FTRClientOfflineQRCodeErrorParsingError = 0,
    FTRClientOfflineQRCodeErrorMissingAccountError = 1,
};

typedef NS_CLOSED_ENUM(NSUInteger, FTRAccountMigrationError) {
    FTRAccountMigrationErrorNoMigrationInfo = 900,
    FTRAccountMigrationErrorAccountsExistError = 901,
    FTRAccountMigrationErrorAccountPreviouslyEnrolledError = 902
};

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

@class FTRTotp;
@class FTRConfig;
@class FTRKitHTTPSessionManager;
@class FTRExtraInfo;

typedef NS_CLOSED_ENUM(NSUInteger, FTRQRCodeType) {
    FTRQRCodeTypeEnrollment,
    FTRQRCodeTypeOnlineAuth,
    FTRQRCodeTypeOfflineAuth,
    FTRQRCodeTypeInvalid
};

typedef void (^FTRRequestHandler)(NSError * _Nullable error);
typedef void (^FTRRequestDataHandler)(id _Nullable data);

@interface FTRClient : NSObject
{
    FTRKitHTTPSessionManager *_sessionManager;
    NSDateFormatter *_rfc2882DateFormatter;
}

+ (NSString * _Nonnull)version;
+ (nullable instancetype)sharedClient;
+ (BOOL)sdkIsLaunched;

+ (void)launchWithConfig:(FTRConfig * _Nonnull)config
                 success:(void (^_Nullable)(void))success
                 failure:(void (^_Nullable)(NSError * _Nonnull))failure;

// public

// Lifecycle

- (void)clearDataFromDB:(BOOL)fromDB
           fromKeychain:(BOOL)fromKeychain;

// Database
- (NSArray<FTRAccount*> * _Nonnull)getAccounts;
- (FTRAccount * _Nonnull)getAccountByUserId:(NSString * _Nonnull)userId;

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
- (void)logoutAccount:(nonnull FTRAccount *)account
             callback:(nullable FTRRequestHandler)callback;

// Accounts status
- (void)getAccountsStatus:(NSArray<FTRAccount*> * _Nonnull)accounts
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
- (void)nextTotpForUserWithBiometrics:(NSString * _Nonnull)userId
                             callback:(void(^_Nonnull)(NSError  * _Nullable error, FTRTotp  * _Nullable totp))callback
                         promptReason:(NSString * _Nonnull)promptReason;
- (FTRTotp * _Nonnull)nextTotpForUser:(NSString * _Nonnull)userId error: (NSError **)error;
- (FTRTotp * _Nonnull)nextTotpForUser:(NSString * _Nonnull)userId
                               SDKPin:(NSString* _Nullable)SDKPin
                                error: (NSError **)error;
/**
 *  This is the method for checking QR Code type based on QR code string.
 *
 *  @param QRCode Provide string directly from scanned QR code image.
 *
 *  @return Returns a QR Code type.
 */

+ (FTRQRCodeType)QRCodeTypeFromQRCode:(NSString *_Nonnull)QRCode;

/**
 *  This is the method for computing offline six digit code based on QR code string.
 *
 *  @param QRCode Provide string directly from scanned QR code image.
 *  @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information.
 *  You may specify nil for this parameter if you do not want the error information.
 *
 *  @return Returns a six digit code in string format. In case any error occurs the method will return nil (objective-c).
 *  In Swift, this method returns a nonoptional result and is marked with the throws keyword to indicate that it throws an error in case of failure.
 */
- (NSString *_Nullable)computeVerificationCodeFromQRCode:(NSString *_Nonnull)QRCode
                                                   error:(NSError *_Nullable*_Nullable)error;
- (void)computeVerificationCodeFromQRCodeWithBiometrics:(NSString *_Nonnull)QRCode
                                               callback:(void(^_Nonnull)(NSError  * _Nullable error,
                                                                    NSString  * _Nullable code))callback
                                           promptReason:(NSString * _Nonnull)promptReason;
- (NSString *_Nullable)computeVerificationCodeFromQRCode:(NSString *_Nonnull)QRCode
                                                  SDKPin:(NSString* _Nullable)SDKPin
                                                   error:(NSError *_Nullable*_Nullable)error;
/**
 *  This is the method for getting extra info (e.g. transaction details) from QR code string
 *  - includes information that must be displayed to the user before they can approve/reject the request.
 *
 *  @param QRCode Provide string directly from scanned QR code image.
 *
 *  @return Returns an array of key value pairs. It will return empty array in case of any error occurs or when extra_info parameter is not provided.
 */

- (NSArray<FTRExtraInfo *> *_Nonnull)extraInfoFromOfflineQRCode:(NSString *_Nonnull)QRCode;

/**
 *  This is the method for checking how many accounts are available to migrate.
 *
 *  @param success The success block to call when checking of account migration is completed successfully.
 *  There is information included of how many accounts are available to migrate.
 *  @param failure The failure block to call when checking of account migration failed.
 *  You can access error's userInfo dictionary to see more readable description of an error.
 *
 */

- (void)checkAccountMigrationPossibleSuccess:(void (^_Nonnull)(NSUInteger numberOfAccountsToMigrate))success
                                     failure:(void (^_Nonnull)(NSError *_Nonnull error))failure;

/**
 *  This is the method for executing account migration. It will succeed if migration data exists on the device and
 *  no accounts currently exist or were previously enrolled on the device.
 *
 *  @param success The success block to call when executing account migration is completed successfully.
 *  There is an array of all accounts that are migrated successfully.
 *  @param failure The failure block to call when executing account migration failed.
 *  You can access error's userInfo dictionary to see more readable description of an error.
 *
 */

- (void)executeAccountMigrationSuccess:(void (^_Nonnull)(NSArray<FTRAccount *> *_Nonnull accountsMigrated))success
                               failure:(void (^_Nonnull)(NSError *_Nonnull error))failure;

//Lock
/**
 Reset the SDK to a clean installation state. This will irreversibly reset the configuration and remove all accounts, keys, secrets and credentials from the SDK.
 */
+ (void)reset;

/**
 Enrolls the user the first time for the BIOMETRICS_OR_SDK_PIN lock configuration type. If you use any other LockConfigurationType during initialization, the method callback will return an error.
 @param code the activation code for the user’s enrollment
 @param SDKPin the SDK PIN the user has provided to the app
 @param callback used to receive the response of the enroll operation
 */
- (void)enrollAndSetupSDKPin:(NSString* _Nonnull)SDKPin
                        code:(NSString * _Nonnull)code
                    callback:(FTRLockHandler _Nullable)callback;

/**
 Query the SDK to find out whether it is unlocked
 */
- (BOOL)isLocked;

/**
 Available  methods for unlocking the SDK
 */
- (NSArray<NSNumber *> * _Nonnull)getActiveUnlockMethods;


/**
 Unlocking method that could be called prior to using a locked functionality, when the SDK is in the BIOMETRICS_ONLY or BIOMETRICS_OR_SDK_PIN configuration. This will display a biometric prompt to authenticate the user and if verification is successful it  will unlock the SDK.
 @param callback used to receive the response of the unlock request
 */
- (void)unlockWithBiometrics:(FTRLockHandler _Nonnull)callback
                promptReason:(NSString * _Nonnull)promptReason;

/**
 Unlocking method that should be called prior to using a locked functionality, when the SDK is in the BIOMETRICS_OR_PASSCODE configuration. This will display a biometric prompt (or passcode authentication) to authenticate the user and depending on its result will unlock the SDK.
 @param callback used to receive the response of the unlock request
 */
- (void)unlockWithBiometricsPasscode:(FTRLockHandler _Nonnull)callback
                        promptReason:(NSString * _Nonnull)promptReason;


/**
 Unlocking method that could be called prior to using a locked functionality, when the SDK is in the BIOMETRICS_OR_SDK_PIN configuration. This will unlock the SDK with the SDK PIN set during enrollment. The app needs to implement the relevant mechanism to ask the user to provide the SDK PIN and then invoke this function.
 @param SDKPin the SDK PIN the user has provided prior to calling the function
 @param callback used to receive the response of the unlock request
 */
- (void)unlockWithSDKPin: (NSString * _Nonnull)SDKPin callback:(FTRLockHandler  _Nonnull)callback;


/**
 Locks the protected functionality of the SDK. Any subsequent call to a locked method will result in FTRLockErrorOperationIsLocked.
 */
- (NSError * _Nullable) lock;

/**
 Activate biometric authentication as a means of convenience so that the user doesn't have to enter the PIN in order to unlock the SDK. This method is only for configuration BIOMETRICS_OR_SDK_PIN
 @return error - Error of this operation.
 */
-(NSError * _Nullable) activateBiometrics;


/**
 Deactivate biometric authentication. This function revokes the biometric authentication capability for unlocking the SDK. This method is only for configuration BIOMETRICS_OR_SDK_PIN
 @return error - Error of this operation.
 */
-(NSError * _Nullable) deactivateBiometrics;

/**
 Change the SDK PIN by providing the existing SDK PIN to authenticate and a new SDK PIN to update to.
 @param newSDKPin - the new SDK PIN to set
 @param callback - used to receive the response of the operation
 */
- (void)changeSDKPin: (NSString * _Nonnull)newSDKPin
            callback:(FTRLockHandler  _Nonnull)callback;

- (SDKState * _Nonnull)getSdkState;

- (BOOL)haveBiometricsChanged;

@end
