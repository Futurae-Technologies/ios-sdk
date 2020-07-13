//
//  FTRNotificationDelegate.h
//  FuturaeKit
//
//  Created by Mike Resvanis on 16/02/2017.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2018 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>

/**
 * The `FTRNotificationDelegate`'s methods allow the delegate to be informed when approve authentication attempts or user unenrolled actions are received via Push Notifications.
 */
@protocol FTRNotificationDelegate <NSObject>

/**
 * Notifies the delegate that an approve authentication attempt has been received.
 *
 * @param authenticationInfo An `<NSDictionary>` object with the respective info for the authentication.
 */
- (void)approveAuthenticationReceived:(nonnull NSDictionary *)authenticationInfo;

/**
 * Notifies the delegate that a user account was unenrolled.
 *
 * @param accountInfo An `<NSDictionary>` object with the respective info for the user account.
 */
- (void)unenrollUserReceived:(nonnull NSDictionary *)accountInfo;

/**
 * Notifies the delegate that an error occurred when processing the push notification payload.
 *
 * @param error An `NSError` object describing the error.
 */
- (void)notificationError:(nonnull NSError *)error;

@end
