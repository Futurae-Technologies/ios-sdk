//
//  FTRMigratableAccount.h
//  FuturaeKit
//
//  Created by Armend Hasani on 28.3.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FTRMigratableAccount : NSObject

@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *username;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END
