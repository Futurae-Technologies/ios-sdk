# Version 2.6.0
2024-11-11
+ [Changed] SSL Pinning is now configurable via the previously deprecated `FTRConfig` parameter `pinCerts`, with pinning enabled by default.
+ [Added] In the event of network request failures due to SSL pinning, the SDK now returns an error object with the code `FTRClientErrorPinCertificate = 511`. For debugging purposes, this error includes the server's public key information in the `publicKeys` key within the `userInfo` object.

# Version 3.4.0
2024-20-09
+ [Changed] SDK no longer relies externally on dependencies RxSwift and SQLite.swift
+ [Added] The SDK returns a specific error for SSL certificate pinning failure: SDKConnectionErrorCode.certPinningFail

# Version 2.5.0
2024-20-09
+ [Added] Added error code `FTRClientErrorPinCertificate` which is returned from the SDK if there is an issue with SSL certificate pinning.
+ [Fixed] Issue where multiple reply authenticaton requests were made when there are multiple accounts enrolled and a public key is submitted before the reply.
+ [Fixed] Issue where SDK becomes corrupt when the SDK is launched while device is locked (more so if SDK was configured to be launched with keychain accessibility attribute `whenDeviceUnlocked` rather than `afterFirstUnock`)
+ [Changed] Replaced a certificate used for SSL pinning.

# Version 3.3.0
2024-09-09
+ [Fixed] Fixed issue where FTRUtils.qrCodeType(from:) would not identify `enrollment` type from scanned enroll QR code
+ [Changed] Configure behaviour for changing SDK PIN with new `LockConfiguration` parameter `pinConfiguration` of type `SDKPinConfiguration` which provides two properties: `allowPinChangeWithBiometricUnlock` (false by default) and `deactivateBiometricsAfterPinChange` (true by default).
+ [Fixed] Fixed issue where SDK would become invalid (failure to decrypt account data) if SDK was launched under one of the following conditions:
1. Keychain configuration accessibility is set to `whenUnlockedThisDeviceOnly` and device is locked
2. Keychain configuration accessibility is set to `afterFirstUnlockThisDeviceOnly` and device has not been unlocked once since device boot

# Version 3.2.4
2024-26-08
+ [Changed] Package.swift file has been updated to use forked version of third party libraries RxSwift and SQLite.swift, which now provide them as dynamic libraries.
+ [Changed] FTRUtils.userId(fromQRCode:) now returns user id from enrollment QR code too besides authentication code.
+ [Changed] Changing SDK PIN is now possible when unlock state is achieved via biometrics
+ [Changed] Changing SDK PIN does not deaactivate biometrics for SDK PIN unlock
+ [Fixed] Issue where `getTOTP` and `getOfflineQRVerificationCode` for SDK PIN lock configuration did not return valid result when used with default parameters

# Version 3.2.3
2024-16-08
+ [Fixed] Issue where upgrading from SDK v2.3.14 and above to SDK v3 resulted in a missing device token/udid error.
+ [Fixed] Issue where `enrolledAt` property of account instance did not provide the exact time.
+ [Added] `SDKReport` instance retrieved via `sdkStateReport` function provides a new property `logs` which contains a log history of internal operations performed by SDK, such as the creation or deletion of keychain items. This log history can be useful for debugging, so it is recommended to share it to us when reporting SDK issues.

# Version 3.2.2
2024-31-07
+ [Fixed] Issue where display name and service name were not updated has been fixed.
+ [Fixed] Issue where SDK PIN error for invalid attempt returned 0 for `attemptsLeft` key when there were more than three attempts left has been fixed.
+ [Added] SDK provides new method to generate an SDK report for debugging purposes. When the SDK returns any errors the report can be retrieved to log it to your provider (Firebase etc.) and then provide it to our Customer Support to help us with debugging the issue.
+ [Added] SDK provides new methods to enable or disable specific Adaptive behavior, such as data collection, adaptive authentication and account migration.
+ [Added] SDK returns specific error when user selects wrong choice for multi number authentication: SDKApiError.wrongMultiNumberChoice
+ [Removed] Expired certificate for SSL pinning has been removed.
+ [Changed] SDK does not perform operations sequentially anymore to avoid delays in execution.
+ [Changed] SDK performs keychain cleanup on fresh install to clear any items from previous installs.
+ [Changed] SDK error descriptions include the description returned from system errors where applicable.
+ [Changed] Other internal improvements


# Version 2.4.2
2024-31-07
+ [Changed] Security enhancements.

# Version 2.4.1
2024-25-07
+ [Added] SDK method `sdkStateReport` to generate a report that includes details about the SDK internals. Include this report in your error logging (Firebase Crashlytics etc.) and share it with the Futurae Customer Support team to help with debugging issues.

# Version 3.2.1
2024-21-06
- [Fixed] Fixes a bug that prevented some users from authenticating and approving transactions in rare migration cases.


# Version 2.4.0
2024-07-06
+ [Fixed] Resolved SDK issues occurring after device backup restoration.
+ [Changed] Deprecated the old `reset` method and introduced a new `reset` method with additional parameters.

# Version 3.2.0
2024-07-06
+ [Fixed] Resolved SDK issues occurring after device backup restoration.
+ [Changed] Deprecated the old `reset` method and introduced a new `reset` method with additional parameters.

# Version 2.3.14
2024-28-05
+ [Changed] Internal improvements

# Version 3.1.9
2024-23-05
+ [Added] Add jailbreak status to certain requests
+ [Fixed] Fix issue for missing value for `enrolled_at` property of account instance

# Version 3.1.8
2024-15-05
### Added
- **Swift Rewrite with Objective-C Compatibility**: Complete rewrite in Swift, offering modern language features while ensuring backward compatibility with Objective-C.
- **New Data Models**: Introduction of strongly typed data models, replacing loosely defined or dictionary-type data for enhanced type safety and predictability.
- **AsyncTask and AsyncTaskResult Classes**: New classes introduced to handle asynchronous operations in Swift, providing an efficient alternative to traditional callback patterns.
- **Enhanced Error Handling**: Robust and informative error handling system implemented. Errors can now be cast to `SDKBaseError` or its subclasses for detailed context and understanding.

### Changed
- **Method Names and Signatures**: Comprehensive update of method names and signatures to align with the Swift codebase. Developers should update their code to match these changes.
- **Consolidated Methods**: Optimization of similar methods, such as merging `approve` and `reject` into a single `replyAuth` method.

### Migration Guide
Users migrating from SDK v2.x.x can follow the detailed step-by-step guide provided. This guide covers acquiring the beta version of the SDK, refactoring application code, and adapting to the significant changes in this version. For more details, check the online iOS SDK guide notes for migrating from SDK v2.x.x to v3.x.x.

### Notes
This release marks a significant update, focusing on enhancing both performance and the development experience. It is recommended for users to migrate to this version to leverage the latest features and improvements.

For a timeline of changes for SDK v3 while in beta stage, please checkout the following link: https://github.com/Futurae-Technologies/ios-sdk-beta/releases

# Version 2.3.13
2024-15-05
+ [Changed] Internal security improvements

# Version 2.3.12
2024-09-05
+ [Changed] Privacy manifest file

# Version 2.3.11
2024-03-05
# Version 2.3.11
2024-03-05
- [Changed] Condition checks related to migration token


# Version 2.3.10
2024-25-04
This release focuses on resolving Apple's requirements for usage of private APIs.
- [Removed] Removed usage of APIs that track disk space. Those were not used by SDK, but the dependency of the SDK.
- [Updated] Added .xcprivacy declaration for UserPreferences API usage.

# Version 2.3.9
2024-14-03
- [Added] Authentication type in dictionary data provided via notification delegate method `approveAuthenticationReceived`
- [Changed] Ensure public key is sent to backend before calling operations that depend on it
- [Changed] SDKLockConfigStatus has been deprecated.
- [Added] Add `FTRUtils` class with convenience methods to retrieve user id or session token from QR code or URI.
- [Changed] Internal improvements


# Version 2.3.8
2023-28-12
- Update to latest FMDB library version
- Internal improvements around database handling

# Version 2.3.7
2023-15-11
+ [Added] a new `FTRAccount.locked_out` field to let SDK know of the account status. It is updated and persisted on SDK launch or on `getAccountsStatus` call. The `getAccounts` call will return the latest known value.


# Version 2.3.6
2023-24-10
+ [Added] Added a new method `checkDataExistsForAppGroup:(NSString *_Nullable)appGroup`. The method checks if SDK data exists for the specified configuration. It may be used to help streamline migration to a new appgroup.


# Version 2.3.5
2023-19-10
+ [Update] Internal security improvements

# Version 2.3.4
2023-13-09
+ [Update] Internal fix that improves SDK versioning tracking

# Version 2.3.3
2023-11-09
+ [Added] Multi number challenge feature where user has to select the correct choice out of multiple numbers to approve authentication
+ [Fixed] App attestation issue where integrity check randomly failed
+ [Fixed] Crash which arises in some cases when updating from older to newer sdk version
+ [Updated] App Attestation method now expects two additional parameters: production and app ID

# Version 2.3.2
2023-16-08
+ [Added] FTRClient function `updateSDKConfig(withAppGroup:keychainConfig:callback:)` to update app group and keychain access group configuration
+ [Updated] FTRConfig's constructors with `pinCerts` are marked as deprecated. The `pinCerts` flag set to false no longer has effect, the SSL pinning is always enabled. SDK will give a warning if client app tries to have SSL pinning disabled.

# Version `2.3.1`
2023-13-07
+ [Added] FTRClient function `decryptExtraInfo` to decrypt extra_info provided in a push notification payload.  
+ [Added] `appGroup` parameter to the `FTRConfig` init method. Passing a value to this parameter as well as the `appGroup` parameter of the `FTRKeychainConfig` init method, makes it possible to use a shared SDK client between apps or extensions (such as the NotificationServiceExtension).
+ [Fix] Bug where the `enrolled` property of the `FTRAccount` object always returns false.
+ [Added] The `userInfo` dictionary of `NSError` instances returned by the SDK may contain a `sdk_error_code` property that corresponds to an `FTRApiError` type.

# Version `2.3.0`
2023-30-06
+ [Added] FTRClient function `enableAdaptiveWithDelegate` function to enable Adaptive.  
+ [Added] FTRClient function `disableAdaptive` to disable Adaptive.  
+ [Added] FTRClient function `isAdaptiveEnabled` to check if Adaptive is enabled.
+ [Added] FTRClient function `setAdaptiveTimeThreshold` to set Adaptive collection interval.
+ [Added] FTRClient function `pendingAdaptiveCollections` to get data collections that are pending sending to backend.
+ [Added] FTRClient function `jailbreakStatus` that returns `JailbreakStatus` object. This object has a BOOL `jailbroken` property that shows if a jailbreak is detected and NSString `message` that contains a description of jailbreak marker if any.

# Version `2.2.1`
2023-08-06

+ [Fix] Handle launch crash in simulator for some iOS 13 versions
+ [Changed] Handle crash on account migration and return error when device UDID or migration token is missing
+ [Changed] Return error from SDK methods when missing device UDID or token

# Version `2.2.0`
2023-16-05

+ [Added] FTRClient functions enrollWithActivationShortCode and enrollAndSetupSDKPin:activationShortCode used for enrolling accounts with activation short codes.
+ [Added] FTRClient functions approveAuthWithUsernamelessQrCode to handle Usernameless QR codes.
+ [Added] FTRClient function QRCodeTypeFromQRCode now can also return value FTRQRCodeTypeUsernameless for usernameless QR codes.

# Version `2.1.0`
2023-14-04

+ [Added] Methods for switching lock configuration
+ [Changed] The method `checkAccountMigrationPossibleSuccess:failure:` has been deprecated. Use instead `checkMigratableAccountsSuccess:failure:` which provides more information about the accounts to be recovered.
+ [Added] Method `executeAccountMigrationWithSDKPin` for completing account migration where SDK PIN is required.
+ [Fixed] Bug where synchronous authentication would fail after first enrollment.
+ [Changed] For config type LockConfigurationTypeBiometricsOrPasscode, if invalidatedByBiometrics is set to true and no biometrics are available (or biometrics are available but permissions are not granted) then the SDK will proceed to function with passcode only.

# Version `2.0.4`
2023-14-02

+ [Added] Token for synchronous authentication 
+ [Added] Retrieve account history
+ [Added] User presence verification parameter in auth endpoints

# Version `2.0.3`
2023-23-01

+ [Fixed] Bug where SDK doesn't properly check for existing RSA keys
+ [Changed] Add condition for sending public key to server based on user defaults value

# Version `2.0.2`
2022-18-10

+ [Changed] Build framework with latest official Xcode release

# Version `2.0.1`
2022-30-09

+ [Changed] Safely insert values in dictionary within openURL method to prevent crashes.

# Version `2.0.0`
2022-30-09

+ Introduces the user presence verification feature.
+ Breaking changes are being introduced - please review the migration guides on the web documentation.

# Version `1.5.2`
2021-30-09

+ [Changed] `uri_success_callback_url` and `uri_failure_callback_url` query parameters are not used in authentication URL anymore. Use `mobile_auth_redirect_uri` instead.
+ [Changed] Disable code coverage

# Version `1.5.1`
2021-10-07

+ [Removed] CFBundleSupportedPlatforms key from the Info.plist file
+ [Changed] Dropped support for iOS 9.0. Bumped deployment target version to iOS 10.0.


# Version `1.6.0`
2022-01-21

+ [Added] (Alpha) Added adaptive authentication library. Disabled by default. Can be enabled for use with automatic account recovery. Please get in touch with us if interested.
+ [Added] `FTRJSONUtils` to parse network error from backend.
+ [Changed] Dropped support for iOS 9.0. Bumped deployment target version to iOS 10.0.

# Version `1.5.0`
2021-10-07

+ [Added] New `keychain` parameter [`FTRKeychainConfig`] in `FTRConfig` methods that allows you to specify Keychain Access Group and Accessibility for keychain items
+ [Removed] `sampleRates` unused property from `FTRConfig`

# Version `1.4.0`
2021-08-12

+ [Added] New `launchWithConfig:` method that does not require `UIApplication` parameter
+ [Changed] Deprecated `launchWithConfig:inApplication:` & `launchWith:config:inApplication` methods, will be removed in next major release

# Version `1.3.0`
2021-05-13

+ [Added] Account migration functionality

# Version `1.2.0`
2021-04-08

+ [Added] Offline QR Code functionality

# Version `1.1.5`
2021-02-04

+ [Added] Function to lookup accounts by both `user_id` and `device_id` simultaneously (useful for handling incoming PNs and ensuring that they were meant for the specific device)
+ [Fixed] Small bugs related to App deletion / backup
+ [Fixed] Bug that could lead to an App crash in rare occasions

# Version `1.1.4`
2021-01-28

+ [Added] arm64 support for iphonesimulator for new M1-chips in xcframework (available manually and through SwiftPM)
+ [Updated] Documentation update on carthage missing iphonesimulator arm64 slice due to existing limitations of carthage 

# Version `1.1.3`
2020-10-15

+ [Added] bitcode Support

# Version `1.1.2`
2020-10-05

+ [Added] SwiftPM Support and relevant Documentation

# Version `1.1.1`
2020-08-28

+ [Fixed] Fix bug in request payload signature generation that was causing the SDK to crash in some not common cases

# Version `1.1.0`
2020-08-19

+ [Added] Carthage Support and relevant Documentation
+ [Added] Models for `FTRAccount` and `FTRTop` replacing untyped `NSDictionary`
+ [Added] New Futurae Client (`FTRClient`) using typed classes
+ [Changed] Deprecated `FuturaeClient`, will be removed in next major release
+ [Changed] Update (`getAccounts`) method to return detailed information about account
+ [Changed] Update FuturaeDemo to use Carthage
+ [Changed] Update FuturaeDemo to use FTRClient and the new typed classes (FTRAccount, FTRTotp)
+ [Deleted] SoundProofKit.framework from project and FuturaeDemo App

# Version `1.0.1`
2020-05-06

+ [Changed] API Update: Separate cleaning DB and keychain data

# Version `1.0.0`
2020-05-04

+ [Added] Support for `mobile_auth_redirect_uri`
+ [Added] SDK version in http header
+ [Added] Validation of SDK ID and Key values
+ [Added] Method to clear SDK data
+ [Fixed] SDK database exlcusion from backup
