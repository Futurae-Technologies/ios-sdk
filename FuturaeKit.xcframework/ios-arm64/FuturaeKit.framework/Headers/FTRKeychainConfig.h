//
//  FTRKeychainConfig.h
//  FuturaeKit
//
//  Created by Mateusz Szklarek on 26/08/2021.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2021 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// An enum whose value indicates when a keychain cryptographic item is accessible.
/// This is used to control the accessibility level of the keychain items which FuturaeKit stores in the iOS Keychain.
///
typedef NS_ENUM(NSUInteger, FTRKeychainItemAccessibility) {
    
    /// This value corresponds to kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly.
    /// For more information refer to:
    /// https://developer.apple.com/documentation/security/ksecattraccessiblewhenpasscodesetthisdeviceonly
    ///
    FTRKeychainItemAccessibilityWhenPasscodeSetThisDeviceOnly,
    
    /// This value corresponds to kSecAttrAccessibleWhenUnlockedThisDeviceOnly.
    ///
    /// For more information refer to:
    /// https://developer.apple.com/documentation/security/ksecattraccessiblewhenunlockedthisdeviceonly
    ///
    FTRKeychainItemAccessibilityWhenUnlockedThisDeviceOnly,
    
    /// This value corresponds to kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly.
    /// This is the default value which FuturaeKit uses, unless specified otherwise.
    /// For more information refer to:
    /// https://developer.apple.com/documentation/security/ksecattraccessibleafterfirstunlockthisdeviceonly
    ///
    FTRKeychainItemAccessibilityAfterFirstUnlockThisDeviceOnly
};

@interface FTRKeychainConfig : NSObject

@property (nonatomic, strong, readonly, nullable) NSString *accessGroup;
@property (nonatomic, assign, readonly) FTRKeychainItemAccessibility itemsAccessibility;

///  Initialize `FTRKeychainConfig` object with keychain access group and items accessibility.
///
///  Both parameters can not be nil.
///
/// - Parameters:
///     - accessGroup: Provide the keychain access group in which FuturaeKit will store its keychain items.
///     - itemsAccessibility Provide the keychain items accessibility which indicates when FuturaeKit keychain items will be accessible.
/// - Returns: `FTRKeychainConfig` object
+ (instancetype)configWithAccessGroup:(NSString *)accessGroup
                   itemsAccessibility:(FTRKeychainItemAccessibility)itemsAccessibility;

///  Initialize `FTRKeychainConfig` object with keychain access group.
///
///  Keychain items accessibility will be set to the default value which is `FTRKeychainItemAccessibilityAfterFirstUnlockThisDeviceOnly`.
///
///  Parameter can not be nil.
///
/// - Parameters:
///     - accessGroup: Provide the keychain access group in which FuturaeKit will store its keychain items.
/// - Returns: `FTRKeychainConfig` object
+ (instancetype)configWithAccessGroup:(NSString *)accessGroup;

///  Initialize `FTRKeychainConfig` object with keychain items accessibility parameter.
///
///  Keychain access group will be set to nil which means that default access group will be used.
///
///  Parameter can not be nil.
///
/// - Parameters:
///     - itemsAccessibility: Provide the keychain items accessibility which indicates when FuturaeKit keychain items will be accessible.
/// - Returns: `FTRKeychainConfig` object
+ (instancetype)configWithItemsAccessibility:(FTRKeychainItemAccessibility)itemsAccessibility;

///  Initialize `FTRKeychainConfig` object with default parameters.
///
///  It will be nil for keychain access group and FTRKeychainItemAccessibilityAfterFirstUnlockThisDeviceOnly for keychain items accessibility.
///
/// - Returns: `FTRKeychainConfig` object
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
