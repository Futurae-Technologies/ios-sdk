//
//  FTRAdaptiveSDKDelegate.h
//  FuturaeKit
//
//  Created by Armend Hasani on 1.11.22.
//  Copyright © 2022 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FTRAdaptivePermissionStatus) {
    FTRAdaptivePermissionStatusUnknown = 0,
    FTRAdaptivePermissionStatusOn = 1,
    FTRAdaptivePermissionStatusOff = 2
};

@protocol FTRAdaptiveSDKDelegate <NSObject>

- (FTRAdaptivePermissionStatus) bluetoothSettingStatus;
- (FTRAdaptivePermissionStatus) bluetoothPermissionStatus;
- (FTRAdaptivePermissionStatus) locationSettingStatus;
- (FTRAdaptivePermissionStatus) locationPermissionStatus;
- (FTRAdaptivePermissionStatus) locationPrecisePermissionStatus;
- (FTRAdaptivePermissionStatus) networkSettingStatus;
- (FTRAdaptivePermissionStatus) networkPermissionStatus;

@optional
- (void)didReceiveUpdateWithCollectedData:(NSDictionary<NSString *,id> *)collectedData;

@end
