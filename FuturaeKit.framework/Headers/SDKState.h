//
//  SDKState.h
//  FuturaeKit
//
//  Created by Armend Hasani on 27.5.22.
//  Copyright © 2022 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, SDKLockStatus) {
    SDKLockStatusLocked = 0,
    SDKLockStatusUnlocked = 1,
};

typedef NS_ENUM(NSUInteger, SDKLockConfigStatus) {
    SDKLockConfigStatusValid = 0,
    SDKLockConfigStatusInvalid = 1,
    SDKLockConfigStatusInvalidBiometricsMissing = 2,
    SDKLockConfigStatusInvalidBiometricsChanged = 3,
    SDKLockConfigStatusInvalidPasscodeMissing = 4,
    SDKLockConfigStatusInvalidPasscodeChanged = 5
};

@interface SDKState : NSObject

@property (nonatomic) SDKLockStatus lockStatus;
@property (nonatomic) SDKLockConfigStatus configStatus;
@property (nonatomic) NSTimeInterval unlockedRemainingDuration;
@property (nonatomic, strong) NSError  * _Nullable error;

-(instancetype)initWithLockStatus: (SDKLockStatus)lockStatus
                  sdkConfigStatus:(SDKLockConfigStatus)configStatus
        unlockedRemainingDuration: (NSTimeInterval)duration
                            error: (NSError * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
