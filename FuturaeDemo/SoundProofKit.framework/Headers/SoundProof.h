//
//  SoundProof.h
//  FuturaeKit
//
//  Created by Dimitris Togias on 23/09/2018.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2018 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// error codes
FOUNDATION_EXTERN const NSUInteger FTRClientErrorMicPermissionDenied;

// notifications
FOUNDATION_EXTERN _Nonnull NSNotificationName const FTRNotificationSoundProofFailed;
FOUNDATION_EXTERN _Nonnull NSNotificationName const FTRNotificationSoundProofSucceeded;
FOUNDATION_EXTERN _Nonnull NSNotificationName const FTRNotificationSoundProofSessionFailed;

@interface SoundProof : NSObject

+ (nullable instancetype)sharedClient;

- (void)handleNotificationForAccount:(NSDictionary * _Nonnull)account
                                info:(NSDictionary * _Nonnull)info
                   completionHandler:(nullable void (^)(UIBackgroundFetchResult result))completionHandler;

@end
