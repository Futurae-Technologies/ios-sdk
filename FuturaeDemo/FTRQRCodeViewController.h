//
//  FTRQrCodeViewController.h
//  FuturaeDemo
//
//  Created by Dimitris Togias on 22/01/2018.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2017 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <UIKit/UIKit.h>

@protocol FTRQRCodeReaderDelegate;

@interface FTRQRCodeViewController : UIViewController

@property(nonatomic, weak) id<FTRQRCodeReaderDelegate> __nullable delegate;

- (void)startScanning;
- (void)stopScanning;

@end

@protocol FTRQRCodeReaderDelegate <NSObject>

@optional
- (void)reader:(FTRQRCodeViewController * _Nullable)reader didScanResult:(NSString *_Nullable)result;
- (void)readerDidCancel:(FTRQRCodeViewController * _Nullable)reader;

@end
