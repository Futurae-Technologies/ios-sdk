//
//  FTRBackendErrorCode.h
//  FuturaeKit
//
//  Created by Valerii on 27.06.2023.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2023 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#ifndef FTRBackendErrorCode_h
#define FTRBackendErrorCode_h

typedef NS_ENUM(NSInteger, FTRBackendErrorCode){
    FTRBackendErrorCodeNoContent = 20400,
    FTRBackendErrorCodeContentNotModified = 30400,
    FTRBackendErrorCodeBadRequest = 40000,
    FTRBackendErrorCodeBadRequestPhoneNumber = 40001,
    FTRBackendErrorCodeBadRequestUsername = 40002,
    FTRBackendErrorCodeBadRequestDisplayName = 40003,
    FTRBackendErrorCodeBadRequestTotp = 40004,
    FTRBackendErrorCodeBadRequestEnrollmentDevice = 40010,
    FTRBackendErrorCodeBadRequestHwTokenPasscode = 40050,
    FTRBackendErrorCodeBadRequestHwTokenService = 40051,
    FTRBackendErrorCodeBadRequestPinUnexpected = 40060,
    FTRBackendErrorCodeBadRequestPinMissing = 40061,
    FTRBackendErrorCodeBadRequestWebAuthCredential = 40090,
    FTRBackendErrorCodeBadRequestWebAuthSession = 40091,
    FTRBackendErrorCodeBadRequestWebAuthCredentialFailed = 40092,
    FTRBackendErrorCodeBadRequestWebAuthExpired = 40093,
    FTRBackendErrorCodeBadRequestWebAuthValidationFailed = 40094,
    FTRBackendErrorCodeUnauthorized = 40100,
    FTRBackendErrorCodeUnauthorizedPinWrongAttempt1 = 40164,
    FTRBackendErrorCodeUnauthorizedPinWrongAttempt2 = 40163,
    FTRBackendErrorCodeUnauthorizedPinWrongAttempt3 = 40162,
    FTRBackendErrorCodeUnauthorizedPinWrongAttempt4 = 40161,
    FTRBackendErrorCodeUnauthorizedSdkPrefix = 40180,
    FTRBackendErrorCodeUnauthorizedSdkEncoding = 40181,
    FTRBackendErrorCodeUnauthorizedSdkFormat = 40182,
    FTRBackendErrorCodeUnauthorizedSdkComponents = 40183,
    FTRBackendErrorCodeUnauthorizedSdkIdentifierFormat = 40184,
    FTRBackendErrorCodeUnauthorizedSdkIdentifier = 40185,
    FTRBackendErrorCodeUnauthorizedSdkCredentials = 40186,
    FTRBackendErrorCodeForbidden = 40300,
    FTRBackendErrorCodeForbiddenByAdaptive = 40302,
    FTRBackendErrorCodeNotFound = 40400,
    FTRBackendErrorCodeDeviceArchived = 41002,
    FTRBackendErrorCodePreconditionFailed = 41200,
    FTRBackendErrorCodeInternalServerError = 50000

};


#endif /* FTRBackendErrorCode_h */
