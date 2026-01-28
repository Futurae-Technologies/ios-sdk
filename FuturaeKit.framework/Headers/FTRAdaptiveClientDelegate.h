//
//  FTRAdaptiveClientDelegate.h
//  FuturaeKit
//
//  Created by Armend Hasani on 12.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

#ifndef FTRAdaptiveClientDelegate_h
#define FTRAdaptiveClientDelegate_h

@protocol FTRAdaptiveClientDelegate <NSObject>
- (void)logCollectedData:(NSDictionary<NSString *,id> *)collectedData retry:(BOOL)retry;
@end

#endif /* FTRAdaptiveClientDelegate_h */
