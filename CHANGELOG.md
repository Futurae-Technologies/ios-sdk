# Version `1.5.3`
2022-10-05

+ [Changed] Safely insert values in dictionary within openURL method to prevent crashes.

# Version `1.5.2`
2022-09-30

+ [Changed] `uri_success_callback_url` and `uri_failure_callback_url` query parameters are not used in authentication URL anymore. Use `mobile_auth_redirect_uri` instead.
+ [Changed] Disable code coverage

# Version `1.5.1`
2021-07-01

+ [Removed] CFBundleSupportedPlatforms key from the Info.plist file
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
