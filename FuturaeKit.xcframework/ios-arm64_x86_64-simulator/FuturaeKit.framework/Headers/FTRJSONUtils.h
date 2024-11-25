//
//  FTRJSONUtils.h
//  FuturaeKit
//
//  Created by Dimitris Togias on 30/09/2018.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2018 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <Foundation/Foundation.h>

@interface FTRJSONUtils : NSObject

/**
 *
 * @param error An error you receive from any kind of request.
 *
 * @returns optional dictionary from JSON error.
 *
 *  Example dictionary from error:
 *  {
 *      "code": 40000,
 *      "error": 1,
 *      "message": "bad request"
 *  }
 *
 */

+ (nullable NSDictionary *)dictionaryFromError:(NSError * _Nullable)error;

@end
