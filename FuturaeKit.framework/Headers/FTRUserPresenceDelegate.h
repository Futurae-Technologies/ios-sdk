//
    //  FTRUserPresenceDelegate.h
//  FuturaeKit
//
//  Created by Armend Hasani on 14.6.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserPresenceVerification.h"

@protocol FTRUserPresenceDelegate <NSObject>

- (UserPresenceVerificationType) userPresenceVerificationType;

@end
