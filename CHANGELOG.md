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
