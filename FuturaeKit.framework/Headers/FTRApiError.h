//
//  FTRApiError.h
//  FuturaeKit
//
//  Created by Armend Hasani on 15.9.22.
//  Copyright © 2022 Futurae. All rights reserved.
//

#ifndef FTRApiError_h
#define FTRApiError_h

typedef NS_ENUM(NSInteger, FTRApiError){
    FTRApiErrorIncorrectPin = 1,
    FTRApiErrorIncorrectPinArchivedDevice = 2,
    FTRApiErrorPinNotNeeded = 3,
    FTRApiErrorMissingPin = 4,
};

#endif /* FTRApiError_h */
