//
//  AppDelegate.h
//  FuturaeDemo
//
//  Created by Dimitris Togias on 27/12/2017.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2017 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <UIKit/UIKit.h>
#import <FuturaeKit/FTRNotificationDelegate.h>
#import <FuturaeKit/FTROpenURLDelegate.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, FTRNotificationDelegate, FTROpenURLDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

