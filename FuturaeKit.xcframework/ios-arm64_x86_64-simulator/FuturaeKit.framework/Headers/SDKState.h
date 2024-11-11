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
    SDKLockConfigStatusValid __attribute__((deprecated)) = 0,
    SDKLockConfigStatusInvalid __attribute__((deprecated)) = 1,
    SDKLockConfigStatusInvalidBiometricsMissing __attribute__((deprecated)) = 2,
    SDKLockConfigStatusInvalidBiometricsChanged __attribute__((deprecated)) = 3,
    SDKLockConfigStatusInvalidPasscodeMissing __attribute__((deprecated)) = 4,
    SDKLockConfigStatusInvalidPasscodeChanged __attribute__((deprecated)) = 5
};

@interface SDKState : NSObject

@property (nonatomic) SDKLockStatus lockStatus;
@property (nonatomic) SDKLockConfigStatus configStatus __attribute__((deprecated));
@property (nonatomic) NSTimeInterval unlockedRemainingDuration;
@property (nonatomic, strong) NSError  * _Nullable error;

-(instancetype)initWithLockStatus: (SDKLockStatus)lockStatus
                  sdkConfigStatus:(SDKLockConfigStatus)configStatus
        unlockedRemainingDuration: (NSTimeInterval)duration
                            error: (NSError * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
