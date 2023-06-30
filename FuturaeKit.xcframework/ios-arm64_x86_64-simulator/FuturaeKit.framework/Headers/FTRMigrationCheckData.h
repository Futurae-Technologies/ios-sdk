//
//  FTRMigrationCheckData.h
//  FuturaeKit
//
//  Created by Armend Hasani on 28.3.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTRMigratableAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface FTRMigrationCheckData : NSObject

@property (nonatomic) NSUInteger numberOfAccountsToMigrate;
@property (nonatomic) BOOL pinProtected;
@property (nonatomic) BOOL adaptiveMigrationEnabled;
@property (nonatomic) NSArray<FTRMigratableAccount*> *migratableAccounts;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END
