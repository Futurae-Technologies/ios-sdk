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
#import <FuturaeKit/FTRAdaptiveSDKDelegate.h>
#import <FuturaeKit/FTRUserPresenceDelegate.h>
#import <FuturaeKit/FTRAccount.h>
#import <FuturaeKit/FTRMigrationCheckData.h>
#import "SDKState.h"
#import "LockConfiguration.h"
#import <FuturaeKit/JailbreakStatus.h>
#import "FTRKeychainConfig.h"


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
    FTRAccountMigrationErrorAccountPreviouslyEnrolledError = 902,
    FTRAccountMigrationErrorPinRequired = 903,
    FTRAccountMigrationErrorNoDeviceUDID = 904,
    FTRAccountMigrationErrorNoMigrationToken = 905
};

// error codes
FOUNDATION_EXTERN const NSUInteger FTRClientErrorGeneric;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorInvalidEnrollmentCode;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorInvalidAuthorizationCode;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorAccountAlreadyActive;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorOutdatedApp;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorMissingDeviceToken;
FOUNDATION_EXTERN const NSUInteger FTRClientErrorMissingDeviceUDID;

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
    FTRQRCodeTypeInvalid,
    FTRQRCodeTypeUsernameless,
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

///  Enroll function with short activation code, for which the app does not provide an SDK Pin.
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
///     - code: the short activation code for the user’s enrollment.
///     - callback: The response of the operation.
///
- (void)enrollWithActivationShortCode:(NSString * _Nonnull)code
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


///  Delete user account from the SDK.
///
///  This is a method that forcefully removes account from the SDK DB.
///  To perform logout under the normal circumstances, please use the designated methods
///     ``logoutUser:callback:`` or ``logoutAccount:callback:``.
///
///  The reason to use this method might be case when account is remotely unenrolled but treated as enrolled by the SDK.
///
/// - Parameters:
///     - userId:  Futurae account's user id that will be deleted.
///     - completionHandler: To get notified about success or failure of this operation.
///
- (void)deleteAccount:(NSString * _Nonnull)userId
             callback:(nullable FTRRequestHandler) completionHandler;

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

///  Get the history of users approve and rejecet operations
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - account:  `FTRAccount` instance for which data be will be fetched.
///     - success: The success block to call when account history was successfully fetched.
///     - failure: The block to execute when the request fails.
///

- (void)getAccountHistory:(FTRAccount * _Nonnull)account
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

///  Approve a usernameless QR Code authentication, when the session includes `extra_info` details.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - qrCode: Provided string directly from scanned QR code image.
///     - userId: Futurae account's user id which the authentication will be binded to.
///     - extraInfo: Session's additional contextual information which is displayed to the user.
///     - callback: To get notified about success or failure of this operation.
///
- (void)approveAuthWithUsernamelessQrCode:(NSString * _Nonnull)qrCode
                                   userId:(NSString * _Nonnull)userId
                                extraInfo:(NSArray * _Nullable)extraInfo
                                 callback:(nullable FTRRequestHandler)callback;

///  Reject a usernameless QR Code authentication, when the session includes `extra_info` details.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - qrCode: Provided string directly from scanned QR code image.
///     - userId: Futurae account's user id which the authentication will be binded to.
///     - isFraud: Flag to choose whether to report a fraudulent authentication attempt.
///     - extraInfo: Session's additional contextual information which is displayed to the user.
///     - callback: To get notified about success or failure of this operation.
///
- (void)rejectAuthWithUsernamelessQrCode:(NSString * _Nonnull)qrCode
                                  userId:(NSString * _Nonnull)userId
                                 isFraud:(Boolean)isFraud
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
///     - multiNumberChoice: Selected number by user for the multi-number challenge
///     - callback: To get notified about success or failure of this operation.
///
- (void)approveAuthWithUserId:(NSString * _Nonnull)userId
                    sessionId:(NSString * _Nonnull)sessionId
                    extraInfo:(NSArray * _Nullable)extraInfo
            multiNumberChoice:(NSNumber * _Nullable)multiNumberChoice
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


///  Approve a usernameless QR Code authentication.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - qrCode: Provided string directly from scanned QR code image.
///     - userId: Futurae account's user id which the authentication will be binded to.
///     - callback: To get notified about success or failure of this operation.
///
- (void)approveAuthWithUsernamelessQrCode:(NSString * _Nonnull)qrCode
                                   userId:(NSString * _Nonnull)userId
                                 callback:(nullable FTRRequestHandler)callback;

///  Reject a usernameless QR Code authentication.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - qrCode: Provided string directly from scanned QR code image.
///     - userId: Futurae account's user id which the authentication will be binded to.
///     - isFraud: Flag to choose whether to report a fraudulent authentication attempt.
///     - callback: To get notified about success or failure of this operation.
///
- (void)rejectAuthWithUsernamelessQrCode:(NSString * _Nonnull)qrCode
                                  userId:(NSString * _Nonnull)userId
                                 isFraud:(Boolean)isFraud
                                callback:(nullable FTRRequestHandler)callback;

///  Accept an Approve (aka. One-touch) authentication.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - userId: Futurae account's user id which the authentication was created for.
///     - sessionId: Session identifier returned by the Futurae backend Auth API.
///     - multiNumberChoice: Selected number by user for the multi-number challenge
///     - callback: To get notified about success or failure of this operation.
///
- (void)approveAuthWithUserId:(NSString * _Nonnull)userId
                    sessionId:(NSString * _Nonnull)sessionId
            multiNumberChoice:(NSNumber * _Nullable)multiNumberChoice
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

///  Return the token for synchronous authentication, for the provided user id.
///
///  This is a protected operation, so the SDK must be unlocked before calling this method.
///
/// - Parameters:
///     - userId: The account’s Futurae user id.
///     - error: A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
///
/// - Returns: Token for synchronous authentication.
- (void)synchronousAuthTokenForUser:(NSString *_Nonnull)userId
                callback:(void(^_Nonnull)(NSError  * _Nullable error, NSString  * _Nullable token))callback;

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
                                     failure:(void (^_Nonnull)(NSError *_Nonnull error))failure __deprecated_msg("Use checkMigratableAccounts: instead");

/// Check which accounts are available to migrate.
///
/// - Parameters:
///   - success: The success block to call when checking of account migration is completed successfully. There is information included of how many accounts are available to migrate and their usernames.
///   - failure: The failure block to call when checking of account migration failed. You can access error's userInfo dictionary to see more readable description of an error.
///
- (void)checkMigratableAccountsSuccess:(void (^_Nonnull)(FTRMigrationCheckData * _Nonnull migrationInfo))success
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

/// Function to execute the Automatic Account Migration, and recover accounts enrolled in a previous installation or device using a SDK Pin.
///
/// For this method to succeed, the device must have valid migration data and no accounts were enrolled before calling this method.
///
/// Provide the SDK Pin that was used during enrollment of the accounts to be migrated or a new SDK Pin if none was used.
///
/// - Parameters:
///   - SDKPin: The SDK Pin required to complete the migration.
///   - success: The success block to call when executing account migration is completed successfully. There is an array of all accounts that are migrated successfully.
///   - failure : The failure block to call when executing account migration failed. You can access error's userInfo dictionary to see more readable description of an error.
///
- (void)executeAccountMigrationWithSDKPin: (NSString * _Nonnull)SDKPin
                                  success:(void (^_Nonnull)(NSArray<FTRAccount *> * _Nonnull))success
                                  failure:(void (^_Nonnull)(NSError * _Nonnull))failure;

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

/// Using a short activation code, enrolls the user's first account when the SDK lock configuration type is `LockConfigurationTypeSDKPinWithBiometricsOptional`, and will result in an error when used with any other lock configuration type.
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
///   - code: The short activation code for the user’s enrollment.
///   - callback: The response of the operation.
///
- (void)enrollAndSetupSDKPin:(NSString* _Nonnull)SDKPin
         activationShortCode:(NSString * _Nonnull)code
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

/// Retrieve the base URL of the SDK configuration
///
/// - Returns: base URL of the SDK configuration
///
- (NSString * _Nonnull)baseURL;

/// Enable adaptive mechanism.
///
/// This method throws an exception error if AdaptiveSDK framework is not imported in the project.
///
/// - Parameters:
///   - delegate: An object that conforms to the FTRAdaptiveSDKDelegate protocol.
- (void)enableAdaptiveWithDelegate:(_Nonnull id<FTRAdaptiveSDKDelegate>)delegate;

/// Disable adaptive mechanism.
- (void)disableAdaptive;

/// Check if adaptive mechanism is enabled.
- (BOOL)isAdaptiveEnabled;

/// When a collection is requested, set the time in seconds for which the last adaptive collection should be returned until a new collection starts.
///
/// - Parameters:
///   - threshold: Threshold in seconds.
- (void)setAdaptiveTimeThreshold: (int)threshold;

/// The SDK will send adaptive collections to the backend, if adaptive mechanism is enabled.
/// If for some reason sending the collections fails, they will move to a pending collection list and the SDK will try to send them again upon next launch.
///
/// - Returns: Array of adaptive collections that are pending sending to backend
///
- (NSArray<NSDictionary<NSString *, id> *> *_Nonnull)pendingAdaptiveCollections;

///
/// Switch to lock configuration of type `LockConfigurationTypeNone`
///
/// - Parameters:
///   - lockConfiguration: The configuration object.
///   - callback: The response of the operation.
///
-(void)switchToLockConfigurationNone:(LockConfiguration *_Nonnull)lockConfiguration
                        callback:(nullable FTRRequestHandler)callback;

///
/// Switch to lock configuration of type `LockConfigurationTypeBiometricsOnly`
///
/// - Parameters:
///   - lockConfiguration: The configuration object.
///   - promptReason: text briefly describing the reason why the biometric authentication is being performed. Will be shown on the Touch ID / Face ID prompt.
///   - callback: The response of the operation.
///
-(void)switchToLockConfigurationBiometrics:(LockConfiguration *_Nonnull)lockConfiguration
                    promptReason:(NSString * _Nullable)promptReason
                        callback:(nullable FTRRequestHandler)callback;

///
/// Switch to lock configuration of type `LockConfigurationTypeBiometricsOrPasscode`
///
/// - Parameters:
///   - lockConfiguration: The configuration object.
///   - promptReason: text briefly describing the reason why the biometric authentication is being performed. Will be shown on the Touch ID / Face ID prompt.
///   - callback: The response of the operation.
///
-(void)switchToLockConfigurationBiometricsOrPasscode:(LockConfiguration *_Nonnull)lockConfiguration
                    promptReason:(NSString * _Nullable)promptReason
                        callback:(nullable FTRRequestHandler)callback;

///
/// Switch to lock configuration of type `LockConfigurationTypeSDKPinWithBiometricsOptional`
///
/// - Parameters:
///   - lockConfiguration: The configuration object.
///   - SDKPin: The SDK Pin provided by the user
///   - callback: The response of the operation.
///
-(void)switchToLockConfigurationSDKPin:(LockConfiguration *_Nonnull)lockConfiguration
                          SDKPin:(NSString* _Nullable)SDKPin
                        callback:(nullable FTRRequestHandler)callback;

- (void)logAnalyticsData:(NSDictionary<NSString *,id> * _Nonnull)analyticsData
                callback:(nullable FTRRequestHandler)callback;

- (void)setUserPresenceDelegate:(id<FTRUserPresenceDelegate> _Nullable)delegate;

///
/// Method used to determine the jailbreak status of the device
///
/// - Returns: `JailbreakStatus` object with the jailbreak status and a message for which jailbreak indicator was detected
///
- (JailbreakStatus *_Nonnull)jailbreakStatus;

///
/// Method using Apple's App Attest service to certify that  a valid instance of the app is installed
///
/// - Parameters:
///   - appId: Team ID + App bundle identifier For example: T82Z6XGNMX.com.futurae.FuturaeDemo.
///   - production: A boolean value which indicates whether the app is in production mode (if built for testflight, app store)
///   - callback: The response of the operation. If error is nil, app instance has been verified.
///
- (void)appAttestation:(NSString * _Nonnull)appId production:(BOOL)production callback:(_Nonnull FTRRequestHandler)callback API_AVAILABLE(ios(14.0));

/// Decrypt extra info that is encrypted and provided from the push notification content
///
///
/// - Parameters:
///    - encryptedExtraInfo: value of `extra_info_enc` key from the notification user info dictionary.
///    - userId: The account’s Futurae user id.
///    - error: A pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
/// - Returns: The decrypted extra info as an array of key value pairs.
///
- (NSArray<NSDictionary *> * _Nullable)decryptExtraInfo:(NSString *_Nonnull)encryptedExtraInfo
                                                 userId:(NSString * _Nonnull)userId
                                                  error:(NSError *_Nullable*_Nullable)error;
///
/// Update SDK configuration with new shared App Group and Keychain Access Group
///
/// This function is protected, therefore the SDK must be unlocked prior to calling it.
///
/// - Parameters:
///   - appGroup: The app group parameter.
///   - keychainConfig: The keychain configuration object. If nil is passed default keychain configuration will be applied.
///   - callback: The response of the operation.
///
-(void)updateSDKConfigWithAppGroup:(NSString *_Nullable)appGroup
                      keychainConfig:(FTRKeychainConfig *_Nullable)keychainConfig
                          callback:(nullable FTRRequestHandler)callback;


///
/// Check if SDK data exists for the specified configuration
///
///
/// - Parameters:
///   - appGroup: The app group parameter.
///   - keychainConfig: The keychain configuration object. If nil is passed default keychain configuration will be applied.
///   - lockConfiguration: The lock configuration object.
///   - callback: The response of the operation.
///
+(BOOL)checkDataExistsForAppGroup:(NSString *_Nullable)appGroup
                   keychainConfig:(FTRKeychainConfig *_Nullable)keychainConfig
                lockConfiguration:(LockConfiguration *_Nonnull)lockConfiguration;
@end
