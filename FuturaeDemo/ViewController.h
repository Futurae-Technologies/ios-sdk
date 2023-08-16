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

@property (weak, nonatomic) IBOutlet UIButton *enableAdaptiveButton;
@property (weak, nonatomic) IBOutlet UIButton *disableAdaptiveButton;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *serviceLogoImageView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *pinButtons;

@property (nonatomic) BOOL enrollWithPin;

- (IBAction)enrollTouchedUpInside:(UIButton *)sender;
- (IBAction)enrollWithPinTouchedUpInside:(UIButton *)sender;
- (IBAction)logoutTouchedUpInside:(UIButton *)sender;
- (IBAction)forceDeleteAccountTouchedUpInside:(UIButton *)sender;
- (IBAction)onlineQRCodeTouchedUpInside:(UIButton *)sender;
- (IBAction)offlineQRCodeTouchedUpInside:(UIButton *)sender;
- (IBAction)totpTouchedUpInside:(UIButton *)sender;
- (IBAction)scanQRCodeTouchedUpInside:(UIButton *)sender;
- (IBAction)totpWithPINTouchedUpInside:(id)sender;
- (IBAction)offlineQRCodeWithPINTouchedUpInside:(id)sender;
- (IBAction)scanQRCodeWithPINTouchedUpInside:(id)sender;
- (IBAction)fetchAccountHistory:(UIButton *)sender;
- (IBAction)adaptiveCollections:(UIButton *)sender;

@end

