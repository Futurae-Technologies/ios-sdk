//
//  FTRConfig.h
//  FuturaeKit
//
//  Created by Dimitris Togias on 27/12/2017.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2018 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>

@interface FTRConfig : NSObject

@property(nonatomic, copy, readonly, nonnull) NSString *apiKey;
@property(nonatomic, copy, readonly, nonnull) NSString *baseUrl;
@property(nonatomic, copy, readonly, nonnull) NSString *locale;
@property(nonatomic, strong, readonly, nonnull) NSArray *capabilities;
@property(nonatomic, strong, readonly, nonnull) NSArray *sampleRates;

+ (nonnull instancetype)configWithApiKey:(NSString * _Nonnull)apiKey;

- (BOOL)isValid;

@end
