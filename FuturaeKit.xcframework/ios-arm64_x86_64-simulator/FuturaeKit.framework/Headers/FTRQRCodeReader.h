//
//  FTRQRCodeReader.h
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
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface FTRQRCodeReader : NSObject

@property(nonatomic, strong, readonly) NSArray * _Nonnull metadataObjectTypes;
@property(nonatomic, strong, readonly) AVCaptureVideoPreviewLayer * _Nonnull previewLayer;
@property(nonatomic, readonly) AVCaptureDeviceInput * _Nonnull defaultDeviceInput;
@property(nonatomic, readonly) AVCaptureDeviceInput * _Nullable frontDeviceInput;
@property(nonatomic, readonly) AVCaptureMetadataOutput * _Nonnull metadataOutput;

+ (nonnull instancetype)reader;
+ (nonnull instancetype)readerWithMetadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;
+ (BOOL)isAvailable;
+ (BOOL)supportsMetadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;
+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (nonnull instancetype)init;
- (nonnull instancetype)initWithMetadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;

- (void)startScanning;
- (void)stopScanning;
- (BOOL)running;
- (void)switchDeviceInput;

- (BOOL)hasFrontDevice;
- (BOOL)isTorchAvailable;
- (void)toggleTorch;
- (void)setCompletionWithBlock:(nullable void (^) (NSString * _Nullable resultAsString))completionBlock;

@end
