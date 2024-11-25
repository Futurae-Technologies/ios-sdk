//
//  FTRAdaptiveConfig.h
//  FuturaeKit
//
//  Created by Mateusz Szklarek on 29/12/2021.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2021 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FTRAdaptiveConfig : NSObject

@property (nonatomic, readonly) BOOL enabled;

+ (instancetype)configWithEnabled:(BOOL)enabled;

/**
 *  Initialize `FTRAdaptiveConfig` object with enabled parameter.
 *
 *  @param enabled Provide the boolean which indicates when FuturaeKit should enable or disable adaptive functionality.
 *
 *  @return `FTRAdaptiveConfig` object
 */

@end

NS_ASSUME_NONNULL_END
