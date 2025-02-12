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
#import <FuturaeKit/LockConfiguration.h>

@class FTRKeychainConfig;

NS_ASSUME_NONNULL_BEGIN

@interface FTRConfig : NSObject

@property (nonatomic, copy, readonly) NSString *sdkKey;
@property (nonatomic, copy, readonly) NSString *sdkId;
@property (nonatomic, copy, readonly) NSString *baseUrl;
@property (nonatomic, copy, readonly) NSString *locale;
@property (nonatomic, copy, readonly) NSString *appGroup;
@property (nonatomic, strong, readonly) NSArray *capabilities;
@property (nonatomic, strong, readonly) FTRKeychainConfig *keychain;
@property (nonatomic, strong, readonly) LockConfiguration *lockConfiguration;
@property (nonatomic) BOOL pinCerts;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
              lockConfiguration: (LockConfiguration * )lockConfiguration;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                       keychain:(FTRKeychainConfig *)keychain
              lockConfiguration: (LockConfiguration * )lockConfiguration;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                        baseUrl:(NSString *)baseUrl
              lockConfiguration: (LockConfiguration * )lockConfiguration;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                        baseUrl:(NSString *)baseUrl
                       keychain:(FTRKeychainConfig *)keychain
              lockConfiguration: (LockConfiguration * )lockConfiguration;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                       pinCerts:(BOOL)pinCerts
              lockConfiguration: (LockConfiguration * )lockConfiguration ;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                       pinCerts:(BOOL)pinCerts
                       keychain:(FTRKeychainConfig *)keychain
              lockConfiguration: (LockConfiguration * )lockConfiguration ;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                        baseUrl:(NSString *)baseUrl
                       pinCerts:(BOOL)pinCerts
              lockConfiguration: (LockConfiguration * )lockConfiguration ;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                        baseUrl:(NSString *)baseUrl
                       pinCerts:(BOOL)pinCerts
                       keychain:(FTRKeychainConfig *)keychain
              lockConfiguration: (LockConfiguration * )lockConfiguration ;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
              lockConfiguration: (LockConfiguration * )lockConfiguration
                       appGroup:(NSString *)appGroup;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                       keychain:(FTRKeychainConfig *)keychain
              lockConfiguration: (LockConfiguration * )lockConfiguration
                       appGroup:(NSString *)appGroup;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                        baseUrl:(NSString *)baseUrl
              lockConfiguration: (LockConfiguration * )lockConfiguration
                       appGroup:(NSString *)appGroup;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                        baseUrl:(NSString *)baseUrl
                       keychain:(FTRKeychainConfig *)keychain
              lockConfiguration: (LockConfiguration * )lockConfiguration
                       appGroup:(NSString *)appGroup;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                       pinCerts:(BOOL)pinCerts
              lockConfiguration: (LockConfiguration * )lockConfiguration
                       appGroup:(NSString *)appGroup ;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                       pinCerts:(BOOL)pinCerts
                       keychain:(FTRKeychainConfig *)keychain
              lockConfiguration: (LockConfiguration * )lockConfiguration
                       appGroup:(NSString *)appGroup ;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                        baseUrl:(NSString *)baseUrl
                       pinCerts:(BOOL)pinCerts
              lockConfiguration: (LockConfiguration * )lockConfiguration
                       appGroup:(NSString *)appGroup ;

+ (instancetype)configWithSdkId:(NSString *)sdkId
                         sdkKey:(NSString *)sdkKey
                        baseUrl:(NSString *)baseUrl
                       pinCerts:(BOOL)pinCerts
                       keychain:(FTRKeychainConfig *)keychain
              lockConfiguration: (LockConfiguration * )lockConfiguration
                       appGroup:(NSString *)appGroup ;

- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
