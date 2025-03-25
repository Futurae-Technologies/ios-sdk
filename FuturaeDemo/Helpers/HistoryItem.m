//
//  HistoryItem.m
//  FuturaeDemo
//
//  Created by Ruben Dudek on 16/01/2023.
//  Copyright © 2023 Futurae. All rights reserved.
//

#import "HistoryItem.h"

@implementation HistoryItem

- (instancetype)initFromAccountHistory:(NSDictionary *)accountHistory
{
    self = [super init];
    if (self == nil) {
        return nil;
    }

    NSDictionary *details = accountHistory[@"details"];
    NSString *result = details[@"result"];
    _success = [result isEqualToString:@"allow"];

    NSString *type = details[@"type"];
    _title = (type && ![type isEqualToString:@""]) ? type : @"Action";

    NSString *ip = details[@"login_device_ip"];
    NSString *ipText = @"No location info";
    if (ip) {
        NSString *countryCode = accountHistory[@"login_dev_country"];
        NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:countryCode];
        ipText = [NSString stringWithFormat:@"%@", ip];
        if (countryName) {
            ipText = [NSString stringWithFormat:@"%@ (%@)", countryName, ipText];
        }
    }
    _subtitle = ipText;
    _result = result;
    
    NSDateFormatter *_historyItemDateFormatter = [[NSDateFormatter alloc] init];
    [_historyItemDateFormatter setLocalizedDateFormatFromTemplate:@"(ddMMMMYYYYjjm)"];

    NSString *unixStr = accountHistory[@"timestamp"];
    NSTimeInterval unix = (NSTimeInterval)[unixStr integerValue];
    _date = [_historyItemDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:unix]];

    return self;
}

@end
