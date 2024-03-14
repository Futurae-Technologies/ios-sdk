//
//  FTRAdaptiveClient.h
//  FuturaeKit
//
//  Created by Armend Hasani on 12.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTRAdaptiveSDKDelegate.h"
#import "FTRAdaptiveClientDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FTRAdaptiveClient : NSObject

@property (nonatomic, copy) void  (^ _Nullable pendingCompletionHandler)(NSDictionary<NSString *,id> *, NSError * _Nullable);

-(instancetype)initWithDelegate:(_Nonnull id<FTRAdaptiveClientDelegate>)delegate;
- (void)startScanningOnce;
- (void)completeScanning;
- (void)deleteCollectedData:(NSDictionary<NSString *,id> *)collectedData;
- (void)enableAdaptiveWithDelegate:(_Nonnull id<FTRAdaptiveSDKDelegate>)delegate;
- (void)disableAdaptive;
- (BOOL)isAdaptiveEnabled;
- (void)setAdaptiveTimeThreshold: (int)threshold;
- (NSArray<NSDictionary<NSString *, id> *> *_Nonnull)pendingAdaptiveCollections;
@end

NS_ASSUME_NONNULL_END
