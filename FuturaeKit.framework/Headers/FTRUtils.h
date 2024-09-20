//
//  FTRUtils.h
//  FuturaeKit
//
//  Created by Armend Hasani on 11.3.24.
//  Copyright © 2024 Futurae. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A utility class to parse values from QR codes and URIs.
@interface FTRUtils : NSObject

/// Extracts the user ID from a QR code string.
/// @param qrCode The QR code string from which to extract the user ID.
/// @return The user ID as a string if found, otherwise `nil`.
+ (NSString * _Nullable)userIdFromQrcode:(NSString *)qrCode;

/// Extracts the session token from a QR code string.
/// @param qrCode The QR code string from which to extract the session token.
/// @return The session token as a string if found, otherwise `nil`.
+ (NSString * _Nullable)sessionTokenFromQrcode:(NSString *)qrCode;

/// Extracts the user ID from a URI string.
/// @param uri The URI string from which to extract the user ID.
/// @return The user ID as a string if found, otherwise `nil`.
+ (NSString * _Nullable)userIdFromUri:(NSString *)uri;

/// Extracts the session token from a URI string.
/// @param uri The URI string from which to extract the session token.
/// @return The session token as a string if found, otherwise `nil`.
+ (NSString * _Nullable)sessionTokenFromUri:(NSString *)uri;

@end

NS_ASSUME_NONNULL_END
