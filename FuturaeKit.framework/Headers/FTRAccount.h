//
//  Account.h
//  FuturaeKit
//
//  Created by Aristeidis Panagiotopoulos on 16/08/2019.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2019 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>

@interface FTRAccount : NSObject

@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *ft_api_server_base_url;
@property (nonatomic) Boolean enrolled;
@property (strong, nonatomic) NSString *device_token;
@property (strong, nonatomic) NSString *service_id;
@property (strong, nonatomic) NSString *device_id;
@property (strong, nonatomic) NSString *service_name;
@property (strong, nonatomic) NSString *enrolled_at;
@property (strong, nonatomic) NSString *updated_at;
@property (strong, nonatomic) NSString *totp_seed;
@property (strong, nonatomic) NSData *encrypted_dt_totp;
@property (strong, nonatomic) NSString *service_logo;
@property (strong, nonatomic) NSArray *allowed_factors;
@property (strong, nonatomic) NSArray *sessions;
@property (nonatomic) Boolean logout_pending;
@property (strong, nonatomic) NSString *hotp_seed;
@property (nonatomic) NSNumber *sync_counter;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
