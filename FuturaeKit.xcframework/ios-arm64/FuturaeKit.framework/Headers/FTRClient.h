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

- (void)clearDataFromDB:(BOOL)fromDB
           fromKeychain:(BOOL)fromKeychain;

/// Get list of enrolled accounts.
///
/// - Returns: `NSArray<FTRAccount*> *` containing the list of enrolled accounts
///
- (NSArray<FTRAccount*> * _Nonnull)getAccounts;

/// Get the account corresponding to the provided user id.
///
/// - Parameters:
///     - userId: The account’s Futurae user id.
/// - Returns: `FTRAccount` instance for the provided `userId`.
///
- (FTRAccount * _Nonnull)getAccountByUserId:(NSString * _Nonnull)userId;


/// Handle URI scheme calls, which can be used either to enroll or authenticate.
///
/// - Parameters:
///    - url: valid url string to be handled by the SDK.
///    - options: options to open the URL
///    - delegate: delegate to be notified about the operation result.
- (BOOL)openURL:(nullable NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> * _Nonnull)options
       delegate:(nullable id<FTROpenURLDelegate>)delegate;

/// Register push notifications token.
///
/// - Parameters:
///    - deviceToken: push notification token obtained from APN.
///
- (void)registerPushToken:(NSData * _Nonnull)deviceToken;

/// Handle a received push notification, and perform the required action.
///
/// This method is protected if the session contains `extra_info`. If that's the case, the SDK needs to be unlocked by verifying the user presence, prior to handling the push notification.
///
/// - Parameters:
///    - payload: received push notification payload.
///    - delegate: delegate to be notified about the operation result.
///
- (void)handleNotification:(NSDictionary * _Nonnull)payload
                  delegate:(nullable id<FTRNotificationDelegate>)delegate;

///  Standard enroll function, for which the app does not provide an SDK Pin.
///
///  It needs to be used for all lock configuration types, with the only exception being that the first enrollment for the `LockConfigurationTypeSDKPinWithBiometricsOptional` lock configuration type needs to take place by using the `enrollAndSetupSDKPin` function.
///
///  This function is protected, therefore the SDK must be unlocked prior to calling it.
///
///  The callback response returns the following errors:
///  - `FTRLockErrorInvalidOperation` if the SDK has been initialized for `LockConfigurationTypeSDKPinWithBiometricsOptional` and this is the very first enrollment. In this case the enrollAndSetupSDKPin should have been used instead.
///  - `FTRLockErrorMechanismUnavailable` if biometric authentication is unavailable`.
///
/// - Parameters:
///     - qrCode: the activation code for the user’s enrollment.
///     - callback: The response of the operation.
///
- (void)enroll:(NSString * _Nonnull)qrCode
      callback:(nullable FTRRequestHandler)callback;

/// Logout the user, in other words to remove the account.
///
/// This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///    - userId:  Futurae account's user id that will be logged out.
///    - callback: to get notified about success or failure of this operation.
///
- (void)logoutUser:(NSString * _Nonnull)userId
          callback:(nullable FTRRequestHandler)callback;

///  Logout the user, in other words to remove the account.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - account:  `FTRAccount` instance that will be logged out.
///     - callback: To get notified about success or failure of this operation.
///
- (void)logoutAccount:(nonnull FTRAccount *)account
             callback:(nullable FTRRequestHandler)callback;

///  Get the status of the provided `accounts` list.
///
/// - Parameters:
///     - accounts: List of `FTRAccount` to check the status for.
///     - success: The success block to call when there are pending sessions.
///     - failure: The block to execute when the request fails.
///
- (void)getAccountsStatus:(NSArray<FTRAccount*> * _Nonnull)accounts
                  success:(nullable FTRRequestDataHandler)success
                  failure:(nullable FTRRequestHandler)failure;

///  Get the session's `extra_info` details, which shall be displayed to the user, before the session being approved.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - userId: Futurae account's user id which the authentication was created for.
///     - sessionId: Session identifier returned by the Futurae backend Auth API.
///     - success: The success block to call when the session was successfully approved.
///     - failure: The block to execute when the request fails.
///
- (void)getSessionInfo:(NSString * _Nonnull)userId
             sessionId:(NSString * _Nonnull)sessionId
               success:(nullable FTRRequestDataHandler)success
               failure:(nullable FTRRequestHandler)failure;

///  Get the session's `extra_info` details, which shall be displayed to the user, before the session being approved.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - userId: Futurae account's user id which the authentication was created for.
///     - sessionToken: Session token identifier, returned by the Futurae Auth API.
///     - success: The success block to call when the session was successfully approved.
///     - failure: The block to execute when the request fails.
///
- (void)getSessionInfo:(NSString * _Nonnull)userId
          sessionToken:(NSString * _Nonnull)sessionToken
               success:(nullable FTRRequestDataHandler)success
               failure:(nullable FTRRequestHandler)failure;

///  Approve an online QR Code authentication, when the session includes `extra_info` details.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - qrCode: Provided string directly from scanned QR code image.
///     - extraInfo: Session's additional contextual information which is displayed to the user.
///     - callback: To get notified about success or failure of this operation.
///
- (void)approveAuthWithQrCode:(NSString * _Nonnull)qrCode
                    extraInfo:(NSArray * _Nullable)extraInfo
                     callback:(nullable FTRRequestHandler)callback;

///  Accept an Approve (aka. One-touch) authentication including `extra_info` data.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - userId: Futurae account's user id which the authentication was created for.
///     - sessionId: Session identifier returned by the Futurae backend Auth API.
///     - extraInfo: Session's additional contextual information which is displayed to the user.
///     - callback: To get notified about success or failure of this operation.
///
- (void)approveAuthWithUserId:(NSString * _Nonnull)userId
                    sessionId:(NSString * _Nonnull)sessionId
                    extraInfo:(NSArray * _Nullable)extraInfo
                     callback:(nullable FTRRequestHandler)callback;

///  Reject an Approve (aka. One-touch) authentication including `extra_info` data.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - userId: Futurae account's user id which the authentication was created for.
///     - sessionId: Session identifier returned by the Futurae backend Auth API.
///     - isFraud: Flag to choose whether to report a fraudulent authentication attempt.
///     - extraInfo: Session's additional contextual information which is displayed to the user.
///     - callback: To get notified about success or failure of this operation.
///
- (void)rejectAuthWithUserId:(NSString * _Nonnull)userId
                   sessionId:(NSString * _Nonnull)sessionId
                     isFraud:(Boolean)isFraud
                   extraInfo:(NSArray * _Nullable)extraInfo
                    callback:(nullable FTRRequestHandler)callback;

///  Approve an online QR Code authentication.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - qrCode: Provided string directly from scanned QR code image.
///     - callback: To get notified about success or failure of this operation.
///
- (void)approveAuthWithQrCode:(NSString * _Nonnull)qrCode
                     callback:(nullable FTRRequestHandler)callback;

///  Accept an Approve (aka. One-touch) authentication.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - userId: Futurae account's user id which the authentication was created for.
///     - sessionId: Session identifier returned by the Futurae backend Auth API.
///     - callback: To get notified about success or failure of this operation.
///
- (void)approveAuthWithUserId:(NSString * _Nonnull)userId
                    sessionId:(NSString * _Nonnull)sessionId
                     callback:(nullable FTRRequestHandler)callback;

///  Reject an Approve (aka. One-touch) authentication.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - userId: Futurae account's user id which the authentication was created for.
///     - sessionId: Session identifier returned by the Futurae backend Auth API.
///     - isFraud: Flag to choose whether to report a fraudulent authentication attempt.
///     - callback: To get notified about success or failure of this operation.
///
- (void)rejectAuthWithUserId:(NSString * _Nonnull)userId
                   sessionId:(NSString * _Nonnull)sessionId
                     isFraud:(Boolean)isFraud
                    callback:(nullable FTRRequestHandler)callback;

///  Return the current 6 digit used in the TOTP offline authentication, for the provided user id.
///
///  This method will trigger a biometric verification before showing the current TOTP, therefore it is only available when the SDK lock configuration type `LockConfigurationTypeSDKPinWithBiometricsOptional`.
///
///  The callback response returns the following errors:
///  - `FTRLockErrorInvalidOperation` if the SDK lock configuration type is other than `LockConfigurationTypeSDKPinWithBiometricsOptional.`
///  - `FTRLockErrorIllegalArgument` if any of the specified values are invalid.
///  - `FTRLockErrorMechanismUnavailable` if biometric authentication is unavailable`.
///
/// - Parameters:
///     - userId: The account’s Futurae user id.
///     - callback: The response of the operation.
///     - promptReason: Text briefly describing the reason why the biometric authentication is being performed. Will be shown on the Touch ID / Face ID prompt.
/// - Returns: Current 6 digit TOTP.
///
- (void)nextTotpForUserWithBiometrics:(NSString * _Nonnull)userId
                             callback:(void(^_Nonnull)(NSError  * _Nullable error, FTRTotp  * _Nullable totp))callback
                         promptReason:(NSString * _Nonnull)promptReason;

///  Return the current 6 digit used in the TOTP offline authentication, for the provided user id.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - userId: The account’s Futurae user id.
///     - error: A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
///
/// - Returns: Current 6 digit TOTP.
///
- (FTRTotp * _Nonnull)nextTotpForUser:(NSString * _Nonnull)userId error:(NSError *_Nullable*_Nullable)error;

///  Return the current 6 digit used in the TOTP offline authentication, for the provided user id.
///
///  This method may be called when the SDK is locked, since the SDKPin is provided as argument. The app must implement a mechanism for the user to insert the SDK Pin.
///
///  The error object contains the following errors:
///  - `FTRLockErrorInvalidOperation` if the SDK lock configuration type is other than `LockConfigurationTypeSDKPinWithBiometricsOptional.`
///  - `FTRLockErrorIllegalArgument` if any of the specified values are invalid.
///
/// - Parameters:
///     - userId: The account’s Futurae user id.
///     - SDKPIn: The SDK Pin inserted by the user
///     - error: A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
/// - Returns: Current 6 digit TOTP.
- (FTRTotp * _Nonnull)nextTotpForUser:(NSString * _Nonnull)userId
                               SDKPin:(NSString* _Nullable)SDKPin
                                error:(NSError *_Nullable*_Nullable)error;
///  Check QR Code type based on QR code string.
///
/// - Parameters:
///     - QRCode: Provide string directly from scanned QR code image.
///
/// - Returns: A QR Code type.
///
+ (FTRQRCodeType)QRCodeTypeFromQRCode:(NSString *_Nonnull)QRCode;

/// Generates the 6-digit confirmation number that the user needs to enter in the browser when authenticating with the offline QR Code Factor, after they approve the authentication or transaction request.
///
/// This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - QRCode: Provide string directly from scanned QR code image.
///     - error: A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
/// - Returns: A six digit code in string format. In case any error occurs the method will return nil (objective-c). In Swift, this method returns a nonoptional result and is marked with the throws keyword to indicate that it throws an error in case of failure.
///
- (NSString *_Nullable)computeVerificationCodeFromQRCode:(NSString *_Nonnull)QRCode
                                                   error:(NSError *_Nullable*_Nullable)error;

/// Generates the 6-digit confirmation number that the user needs to enter in the browser when authenticating with the offline QR Code Factor, after they approve the authentication or transaction request.
///
/// This method was designed for the case when the app is offline, the SDK is configured with `LockConfigurationTypeSDKPinWithBiometricsOptional`, and the user presence was validated using biometrics authentication.
///
/// The callback response returns the following errors:
/// - `FTRLockErrorInvalidOperation` if the SDK lock configuration type is other than `LockConfigurationTypeSDKPinWithBiometricsOptional.`
/// - `FTRLockErrorIllegalArgument` if any of the specified values are invalid.
/// - `FTRLockErrorMechanismUnavailable` if biometric authentication is unavailable`.
///
/// - Parameters:
///     - QRCode: Provide string directly from scanned QR code image.
///     - callback: The response of the operation.
///     - promptReason: Text briefly describing the reason why the biometric authentication is being performed. Will be shown on the Touch ID / Face ID prompt.
/// - Returns: A six digit code in string format. In case any error occurs the method will return nil (objective-c). In Swift, this method returns a nonoptional result and is marked with the throws keyword to indicate that it throws an error in case of failure.
///
- (void)computeVerificationCodeFromQRCodeWithBiometrics:(NSString *_Nonnull)QRCode
                                               callback:(void(^_Nonnull)(NSError  * _Nullable error,
                                                                    NSString  * _Nullable code))callback
                                           promptReason:(NSString * _Nonnull)promptReason;

/// Generates the 6-digit confirmation number that the user needs to enter in the browser when authenticating with the offline QR Code Factor, after they approve the authentication or transaction request.
///
/// This method with the `SDKPin` argument was designed for the case when the app is offline, the SDK is configured with `LockConfigurationTypeSDKPinWithBiometricsOptional`, and the user presence was validated using the SDK Pin.
///
/// The callback response returns the following errors:
/// - `FTRLockErrorInvalidOperation` if the SDK lock configuration type is other than `LockConfigurationTypeSDKPinWithBiometricsOptional.`
/// - `FTRLockErrorIllegalArgument` if any of the specified values are invalid.
///
/// - Parameters:
///     - QRCode: Provide string directly from scanned QR code image.
///     - SDKPin: The SDK Pin inserted by the user
///     - error: A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
/// - Returns: A six digit code in string format. In case any error occurs the method will return nil (objective-c). In Swift, this method returns a nonoptional result and is marked with the throws keyword to indicate that it throws an error in case of failure.
///
- (NSString *_Nullable)computeVerificationCodeFromQRCode:(NSString *_Nonnull)QRCode
                                                  SDKPin:(NSString* _Nullable)SDKPin
                                                   error:(NSError *_Nullable*_Nullable)error;

/// Get extra info (e.g. transaction details) from QR code string
///
/// Includes information that must be displayed to the user before they can approve/reject the request.
///
/// - Parameters:
///     - QRCode: Provide string directly from scanned QR code image.
/// - Returns: An array of key value pairs. It will return empty array in case of any error occurs or when extra_info parameter is not provided.
///
- (NSArray<FTRExtraInfo *> *_Nonnull)extraInfoFromOfflineQRCode:(NSString *_Nonnull)QRCode;


/// Check how many accounts are available to migrate.
///
/// - Parameters:
///   - success: The success block to call when checking of account migration is completed successfully. There is information included of how many accounts are available to migrate.
///   - failure: The failure block to call when checking of account migration failed. You can access error's userInfo dictionary to see more readable description of an error.
///
- (void)checkAccountMigrationPossibleSuccess:(void (^_Nonnull)(NSUInteger numberOfAccountsToMigrate))success
                                     failure:(void (^_Nonnull)(NSError *_Nonnull error))failure;

/// Function to execute the Automatic Account Migration, and recover accounts enrolled in a previous installation or device.
///
/// For this method to succeed, the device must have valid migration data and no accounts were enrolled before calling this method.
///
/// This method is protected in case that the SDK is configured with `LockConfigurationTypeBiometricsOnly` or `LockConfigurationTypeBiometricsOrPasscode`, and in those cases, the SDK will need to be unlocked prior to calling this function.
///
/// - Parameters:
///   - success: The success block to call when executing account migration is completed successfully. There is an array of all accounts that are migrated successfully.
///   - failure: The failure block to call when executing account migration failed. You can access error's userInfo dictionary to see more readable description of an error.
///
- (void)executeAccountMigrationSuccess:(void (^_Nonnull)(NSArray<FTRAccount *> *_Nonnull accountsMigrated))success
                               failure:(void (^_Nonnull)(NSError *_Nonnull error))failure;


/// Reset the SDK to a clean installation state. This will irreversibly reset the configuration and remove all accounts, keys, secrets, credentials and lock configurations from the SDK.
+ (void)reset;

/// Enrolls the user's first account when the SDK lock configuration type is `LockConfigurationTypeSDKPinWithBiometricsOptional`, and will result in an error when used with any other lock configuration type.
///
/// This method shall only be used on the first enrollment, if the device has no accounts enrolled beforehand. For subsequent enrollments, the `enroll` method shall be used instead.
///
/// This function unlocks the SDK, for the configured `unlockDuration`, upon success.
///
/// The callback response returns the following errors:
/// - `FTRLockErrorInvalidOperation` if the current SDK configuration does not support biometric authentication.
/// - `FTRLockErrorIllegalArgument` if any of the specified arguments are invalid.
///
///
/// - Parameters:
///   - SDKPin: The SDK Pin which the user has provided to the app.
///   - code: The activation code for the user’s enrollment.
///   - callback: The response of the operation.
///
- (void)enrollAndSetupSDKPin:(NSString* _Nonnull)SDKPin
                        code:(NSString * _Nonnull)code
                    callback:(FTRLockHandler _Nullable)callback;

/// Query the SDK to find out whether it is unlocked.
///
/// - Returns: `true` if the SDK is locked, otherwise returns `false`.
- (BOOL)isLocked;

/// Returns a list of `UnlockMethodType` enum values that the SDK can currently be unlocked with.
///
/// The mapping of the returned numbers is:
/// - UnlockMethodTypeBiometric = 1
/// - UnlockMethodTypeBiometricsOrPasscode = 2
/// - UnlockMethodTypeSDKPin = 3
/// - UnlockMethodTypeNone = 4
///
/// - Returns: An array of `NSNumber` with the currently active unlock methods, which can be used to verify the user presence and therefore unlock the SDK.
///
- (NSArray<NSNumber *> * _Nonnull)getActiveUnlockMethods;

/// Unlocking method that could be called prior to using a locked functionality, when the SDK is in the `LockConfigurationTypeBiometricsOnly` or `LockConfigurationTypeSDKPinWithBiometricsOptional` configuration.
///
/// This will display a biometric prompt for the user to authenticate on, and if the verification is successful the SDK will be unlocked for the configured `unlockDuration`.
///
/// The callback response returns the following errors:
/// - `FTRLockErrorInvalidOperation` if the current SDK configuration does not support biometric authentication.
/// - `FTRLockErrorMechanismUnavailable` if none of the supported authentication methods are available.
/// - `FTRLockErrorBiometricsInvalidated` if the biometrics of the device have been changed or invalidated.
///
///
/// - Parameters:
///   - callback: The response of the operation.
///   - promptReason: text briefly describing the reason why the biometric authentication is being performed. Will be shown on the Touch ID / Face ID prompt.
///
///
- (void)unlockWithBiometrics:(FTRLockHandler _Nonnull)callback
                promptReason:(NSString * _Nonnull)promptReason;

/// Unlocking method that should be called prior to using a locked functionality, when the SDK is in the `LockConfigurationTypeBiometricsOrPasscode` configuration.
///
/// This will display a biometric prompt (or passcode authentication) to authenticate the user and, in case that user presence is successfully verified, the SDK will be unlocked for configured `unlockDuration`
///
/// The callback response returns the following errors:
/// - `FTRLockErrorMechanismUnavailable` if none of the supported authentication methods are available.
/// - `FTRLockErrorBiometricsInvalidated` if the biometrics of the device have been changed or invalidated.
///
///
/// - Parameters:
///   - callback: The response of the operation.
///   - promptReason: Text briefly describing the reason why the biometric authentication is being performed. Will be shown on the Touch ID / Face ID prompt.
///
///
- (void)unlockWithBiometricsPasscode:(FTRLockHandler _Nonnull)callback
                        promptReason:(NSString * _Nonnull)promptReason;

/// Unlocking method that could be called prior to using a locked functionality, when the SDK is in the `LockConfigurationTypeSDKPinWithBiometricsOptional` configuration.
///
/// This function is used to unlock the SDK by validating the SDK Pin which was set during enrollment.
///
/// The app needs to implement the relevant mechanism to ask the user to provide the SDK Pin and then invoke this function.
///
/// The callback response returns the following errors:
/// - `FTRLockErrorInvalidOperation` if the SDK lock configuration type is other than `LockConfigurationTypeSDKPinWithBiometricsOptional.`
/// - `FTRLockErrorIllegalArgument` if any of the specified values are invalid.
///
///
/// - Parameters:
///   - SDKPin: The SDK Pin the user has provided prior to calling the function.
///   - callback: The response of the operation.
///
- (void)unlockWithSDKPin: (NSString * _Nonnull)SDKPin callback:(FTRLockHandler  _Nonnull)callback;


/// Locks the SDK.
///
/// Any subsequent call to a protected operation will result  in an `FTRLockErrorOperationIsLocked` error.
///
/// This method returns an error of type `FTRLockErrorInvalidConfiguration`if the SDK is configured with LockConfigurationTypeNone
///
/// - Returns: An optional error.
///
- (NSError * _Nullable) lock;

/// Activate the biometric authentication as a means of convenience to verify the user presence, so that the user doesn't have to enter the Pin to unlock the SDK.
///
/// This method is only availble when the SDK lock configuration type is `LockConfigurationTypeSDKPinWithBiometricsOptional`.
///
/// This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// This method returns an error of type `FTRLockErrorInvalidOperation` if the SDK lock configuration type is other than `LockConfigurationTypeSDKPinWithBiometricsOptional.`
///
/// - Returns: An optional error.
///
-(NSError * _Nullable) activateBiometrics;

/// Deactivate biometrics as an authentication method.
///
/// This function revokes the biometric authentication capability for unlocking the SDK.
///
/// This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// This method returns an error of type `FTRLockErrorInvalidOperation` if the SDK lock configuration type is other than `LockConfigurationTypeSDKPinWithBiometricsOptional.`
///
/// - Returns: An optional error.
///
-(NSError * _Nullable) deactivateBiometrics;

/// Change the SDK Pin.
///
/// This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// The callback response returns the following errors:
/// - `FTRLockErrorInvalidOperation` if the SDK lock configuration type is other than `LockConfigurationTypeSDKPinWithBiometricsOptional.`
/// - `FTRLockErrorOperationIsLocked` if the SDK was not unlocked using `unlockWithSDKPin` function.
/// - `FTRLockErrorIllegalArgument` if any of the specified values are invalid.
///
///
/// - Parameters:
///   - newSDKPin: The new SDK Pin.
///   - callback: The response of the operation.
///
- (void)changeSDKPin: (NSString * _Nonnull)newSDKPin
            callback:(FTRLockHandler  _Nonnull)callback;

/// Get information about the state of the SDK , such as lock status and remaining unlocked duration.
///
/// - Returns: `SDKState` object
///
- (SDKState * _Nonnull)getSdkState;

/// Check if the device's biometrics settings have been changed, which renders the SDK biometrics invalid.
///
/// - Returns: `true` if the biometrics keys have been changed, othewise returns `false`.
///
- (BOOL)haveBiometricsChanged;

@end
