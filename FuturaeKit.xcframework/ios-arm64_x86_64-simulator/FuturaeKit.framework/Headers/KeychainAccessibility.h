#import <Foundation/Foundation.h>
#import "FTRKeychainConfig.h"

typedef NS_ENUM(NSUInteger, KeychainItemAccessibility) {
    KeychainItemAccessibilityWhenUnlocked,
    KeychainItemAccessibilityAfterFirstUnlock,
    KeychainItemAccessibilityWhenPasscodeSetThisDeviceOnly,
    KeychainItemAccessibilityWhenUnlockedThisDeviceOnly,
    KeychainItemAccessibilityAfterFirstUnlockThisDeviceOnly
};

@interface KeychainAccessibility : NSObject

+ (KeychainItemAccessibility)itemAccessibilityFrom:(FTRKeychainItemAccessibility)accessibility;
+ (NSString *)rawValueFor:(enum KeychainItemAccessibility)accessibility;

@end
