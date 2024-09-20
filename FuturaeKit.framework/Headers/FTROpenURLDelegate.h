//
//  FTROpenURLDelegate.h
//  FuturaeKit
//
//  Created by Mike Resvanis on 07/03/2018.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2018 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>

/**
 * The `FTROpenURLDelegate`'s methods allow the delegate to be informed when authentication or
 * activation URLs are opened.
 */
@protocol FTROpenURLDelegate <NSObject>

/**
 * Notifies the delegate that an authentication URL was just opened.
 *
 * @param authenticationInfo An `<NSDictionary>` object with the respective authentication info.
 */
- (void)authenticationURLOpened:(nonnull NSDictionary *)authenticationInfo;

/**
 * Notifies the delegate that an activation URL was just opened.
 *
 * @param activationInfo An `<NSDictionary>` object with the respective info for the activation info.
 */
- (void)activationURLOpened:(nonnull NSDictionary *)activationInfo;

/**
 * Notifies the delegate that an error occurred when processing the URL just opened.
 *
 * @param error An `NSError` object describing the error.
 */
- (void)openURLError:(nonnull NSError *)error;

@end
