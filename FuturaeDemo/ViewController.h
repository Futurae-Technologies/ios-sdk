//
//  ViewController.h
//  FuturaeDemo
//
//  Created by Dimitris Togias on 27/12/2017.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2017 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)enrollTouchedUpInside:(UIButton *)sender;
- (IBAction)logoutTouchedUpInside:(UIButton *)sender;
- (IBAction)onlineQRCodeTouchedUpInside:(UIButton *)sender;
- (IBAction)offlineQRCodeTouchedUpInside:(UIButton *)sender;
- (IBAction)totpTouchedUpInside:(UIButton *)sender;
- (IBAction)scanQRCodeTouchedUpInside:(UIButton *)sender;

@end

