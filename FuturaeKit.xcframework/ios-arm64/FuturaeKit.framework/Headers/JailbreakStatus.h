//
//  JailbreakStatus.h
//  FuturaeKit
//
//  Created by Armend Hasani on 21.6.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JailbreakStatus : NSObject


@property (nonatomic) Boolean jailbroken;
@property (strong, nonatomic) NSString *message;

- (instancetype)init:(Boolean)jailbroken message:(NSString *) message;

@end

NS_ASSUME_NONNULL_END
