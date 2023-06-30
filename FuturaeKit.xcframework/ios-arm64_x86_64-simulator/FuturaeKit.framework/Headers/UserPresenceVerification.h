//
//  UserPresenceVerification.h
//  FuturaeKit
//
//  Created by Ruben Dudek on 13/01/2023.
//  Copyright © 2023 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FTRUserPresenceDelegate;

@import LocalAuthentication;

typedef NS_ENUM(NSUInteger, UserPresenceVerificationType) {
    UserPresenceVerificationTypeBiometricsIosTouchId = 0,
    UserPresenceVerificationTypeBiometricsIosFaceId = 1,
    UserPresenceVerificationTypeAppSpecificPin = 2,
    UserPresenceVerificationTypeDeviceCredentialsIosPasscode = 3,
    UserPresenceVerificationTypePasscodeOrBiometrics = 4,
    UserPresenceVerificationTypeNone = 5,
    UserPresenceVerificationTypeUnknown = 6
};

NS_ASSUME_NONNULL_BEGIN

@interface UserPresenceVerification : NSObject {
    LAContext *context;
}
   
@property (nonatomic) UserPresenceVerificationType verificationType;

+ (id)shared;
- (NSString *)getStringValue;
- (void)setUpUserPresenceWithType:(UserPresenceVerificationType)type;
- (void)setUserPresenceDelegate:(id<FTRUserPresenceDelegate> _Nullable) delegate;
- (void)checkBiometryType;

@end

NS_ASSUME_NONNULL_END
