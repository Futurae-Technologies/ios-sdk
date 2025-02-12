//
//  FTRTotp.h
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

@interface FTRTotp : NSObject

@property (strong, nonatomic) NSString *totp;
@property (strong, nonatomic) NSString *remaining_secs;

@end
