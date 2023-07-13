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
    FTRApiErrorUnhandledError = 0,
    FTRApiErrorIncorrectPin = 1,
    FTRApiErrorIncorrectPinArchivedDevice = 2,
    FTRApiErrorPinNotNeeded = 3,
    FTRApiErrorMissingPin = 4,
    FTRApiErrorNoContent = 5,
    FTRApiErrorContentNotModified = 6,
    FTRApiErrorBadRequest = 7,
    FTRApiErrorOperationForbidden = 8,
    FTRApiErrorRouteNotFound = 9,
    FTRApiErrorPreconditionFailed = 10,
    FTRApiErrorAuthorizationFailed = 11,
    FTRApiErrorInternalServerException = 12,
    FTRApiErrorDeviceArchived = 13,
    FTRApiErrorAdaptiveMigrationFailed = 14
};

#endif /* FTRApiError_h */
