//
//  HistoryItem.h
//  FuturaeDemo
//
//  Created by Ruben Dudek on 16/01/2023.
//  Copyright © 2023 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistoryItem : NSObject

@property (nonatomic, assign) BOOL success;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *result;

- (instancetype)initFromAccountHistory:(NSDictionary *)accountHistory;

@end

NS_ASSUME_NONNULL_END
