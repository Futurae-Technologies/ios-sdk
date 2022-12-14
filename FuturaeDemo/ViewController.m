//
//  ViewController.m
//  FuturaeDemo
//
//  Created by Dimitris Togias on 27/12/2017.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2017 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import "ViewController.h"

#import "FTRQRCodeViewController.h"
#import <FuturaeKit/FuturaeKit.h>
#import "NSArray+Map.h"
#import "FuturaeDemo-Swift.h"

////////////////////////////////////////////////////////////////////////////////
@interface ViewController () <FTRQRCodeReaderDelegate>
{
    NSDateFormatter *_rfc2882DateFormatter;
}

@end

////////////////////////////////////////////////////////////////////////////////
@implementation ViewController

NSString * _Nullable offlineQRCodePin;
BOOL operationWithBiometrics = NO;

#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _messageLabel.hidden = FTRClient.sdkIsLaunched;
    _stackView.hidden = !FTRClient.sdkIsLaunched;
    BOOL isNotPinView = LockConfiguration.get.type != LockConfigurationTypeSDKPinWithBiometricsOptional;
    for (UIButton *btn in _pinButtons) {
        [btn setHidden:isNotPinView];
    }
}

#pragma mark - Handlers
////////////////////////////////////////////////////////////////////////////////
- (IBAction)enrollTouchedUpInside:(UIButton *)sender
{
    self.enrollWithPin = NO;
    [self presentQRCodeControllerWithQRCodeType:QRCodeTypeEnrollment sender:sender];
}

- (IBAction)enrollWithPinTouchedUpInside:(UIButton *)sender
{
    self.enrollWithPin = YES;
    [self presentQRCodeControllerWithQRCodeType:QRCodeTypeEnrollment sender:sender];
}

////////////////////////////////////////////////////////////////////////////////
- (IBAction)logoutTouchedUpInside:(UIButton *)sender
{
    // For demo purposes we simply logout the first account we can find
    FTRAccount *account = [[FTRClient sharedClient] getAccounts].firstObject;
    if (account == nil) {
        [self _showAlertWithTitle:@"Error" message:@"No user enrolled"];
        return;
    }
    
    [[FTRClient sharedClient] logoutUser:account.user_id callback:^(NSError * _Nullable error) {
        
        if(error){
            [self _showAlertWithTitle:@"Error" message: error.userInfo[@"msg"] ? error.userInfo[@"msg"] : error.localizedDescription];
        } else {
            [self _showAlertWithTitle:@"Success" message:[NSString stringWithFormat:@"Logged out user %@", account.username]];
        }
    }];
}

////////////////////////////////////////////////////////////////////////////////
- (IBAction)onlineQRCodeTouchedUpInside:(UIButton *)sender
{
    [self presentQRCodeControllerWithQRCodeType:QRCodeTypeOnlineAuth sender:sender];
}

////////////////////////////////////////////////////////////////////////////////
- (IBAction)offlineQRCodeTouchedUpInside:(UIButton *)sender
{
    [self presentQRCodeControllerWithQRCodeType:QRCodeTypeOfflineAuth sender:sender];
}

- (IBAction)offlineQRCodeWithPINTouchedUpInside:(id)sender {
    __weak __typeof(self) weakSelf = self;
    
    PinViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinViewController"];
    [vc setPinModeWithMode:@"set"];
    [vc setDidFinishWithPinWithCallback:^(NSString * _Nullable pin) {
        offlineQRCodePin = pin;
        [self presentQRCodeControllerWithQRCodeType:QRCodeTypeOfflineAuth sender:sender];
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf presentViewController:vc animated:true completion:nil];
    }];
}

- (IBAction)offlineQRCodeWithBiometricsTouchedUpInside:(id)sender {
    operationWithBiometrics = YES;
    [self presentQRCodeControllerWithQRCodeType:QRCodeTypeOfflineAuth sender:sender];
}

- (IBAction)totpTouchedUpInside:(UIButton *)sender
{
    [self totpAuth:nil];
}

- (IBAction)totpWithBiometricsTouchedUpInside:(id)sender {
    operationWithBiometrics = YES;
    [self totpAuth:nil];
}

- (IBAction)totpWithPINTouchedUpInside:(id)sender {
    __weak __typeof(self) weakSelf = self;
    
    PinViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinViewController"];
    [vc setPinModeWithMode:@"set"];
    [vc setDidFinishWithPinWithCallback:^(NSString * _Nullable pin) {
        [weakSelf totpAuth:pin];
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf presentViewController:vc animated:true completion:nil];
    }];
}

- (void)totpAuth:(NSString * _Nullable) SDKPin {
    __weak __typeof(self) weakSelf = self;
    FTRAccount *account = [[FTRClient sharedClient] getAccounts].firstObject;
    NSError *error;
    FTRTotp *totp;
    if(operationWithBiometrics){
        operationWithBiometrics = NO;
        [[FTRClient sharedClient] nextTotpForUserWithBiometrics:account.user_id callback:^(NSError * _Nullable err, FTRTotp * _Nullable totp) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(err){
                    [weakSelf _showAlertWithTitle:@"Error" message:err.userInfo[@"msg"]];
                    return;
                } else {
                    NSString *title = @"TOTP";
                    NSString *body = [NSString stringWithFormat:@"Code: %@ (remaining: %@ sec)", totp.totp, totp.remaining_secs];
                    [weakSelf _showAlertWithTitle:title message:body];
                }
            });
            
        } promptReason:@"Unlock SDK"];
    } else {
        totp = [[FTRClient sharedClient] nextTotpForUser:account.user_id SDKPin: SDKPin error:&error];
        if (error) {
            [self _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
            return;
        }
        
        NSString *title = @"TOTP";
        NSString *body = [NSString stringWithFormat:@"Code: %@ (remaining: %@ sec)", totp.totp, totp.remaining_secs];
        [self _showAlertWithTitle:title message:body];
    }
}

- (IBAction)scanQRCodeTouchedUpInside:(UIButton *)sender
{
    [self presentQRCodeControllerWithQRCodeType:QRCodeTypeGeneric sender:sender];
}

- (IBAction)scanQRCodeWithPINTouchedUpInside:(id)sender {
    __weak __typeof(self) weakSelf = self;
    
    PinViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinViewController"];
    [vc setPinModeWithMode:@"set"];
    [vc setDidFinishWithPinWithCallback:^(NSString * _Nullable pin) {
        offlineQRCodePin = pin;
        [self presentQRCodeControllerWithQRCodeType:QRCodeTypeGeneric sender:sender];
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf presentViewController:vc animated:true completion:nil];
    }];
}

- (IBAction)scanQRCodeWithBiometricsTouchedUpInside:(id)sender {
    operationWithBiometrics = YES;
    [self presentQRCodeControllerWithQRCodeType:QRCodeTypeGeneric sender:sender];
}

- (IBAction)checkAccountMigrationTouchedUpInside:(UIButton *)sender
{
    __weak __typeof(self) weakSelf = self;
    [FTRClient.sharedClient checkAccountMigrationPossibleSuccess:^(NSUInteger numberOfAccountsToMigrate) {
        NSString *title = @"Checking account migration succeeds";
        NSString *message = [NSString stringWithFormat:@"Number of accounts to migrate: %lu",
                             (unsigned long)numberOfAccountsToMigrate];
        [weakSelf _showAlertWithTitle:title message:message];
    } failure:^(NSError * _Nonnull error) {
        NSString *title = @"Checking account migration failed";
        NSString *message = [error.userInfo.allValues componentsJoinedByString:@", "];
        [weakSelf _showAlertWithTitle:title message:message];
    }];
}

- (IBAction)executeAccountMigrationTouchedUpInside:(UIButton *)sender
{
    __weak __typeof(self) weakSelf = self;
    [FTRClient.sharedClient executeAccountMigrationSuccess:^(NSArray<FTRAccount *> * _Nonnull accountsMigrated) {
        NSString *title = @"Executing account migration succeeds";
        NSArray<NSString *> *usernames = [accountsMigrated map:^NSString *_Nonnull(FTRAccount *account) {
            return account.username ? account.username : @"";
        }];
        NSString *joinedUsernames = [usernames componentsJoinedByString:@"\n"];
        NSString *message = [NSString stringWithFormat:@"Migrated accounts [%lu]:\n\n%@",
                             (unsigned long)accountsMigrated.count,
                             joinedUsernames];
        [weakSelf _showAlertWithTitle:title message:message];
    } failure:^(NSError * _Nonnull error) {
        NSString *title = @"Executing account migration failed";
        NSString *message = [error.userInfo.allValues componentsJoinedByString:@", "];
        [weakSelf _showAlertWithTitle:title message:message];
    }];
}

#pragma mark - FTRQRCodeReaderDelegate
////////////////////////////////////////////////////////////////////////////////
- (void)reader:(FTRQRCodeViewController * _Nullable)reader didScanResult:(NSString *_Nullable)result
{
    // TODO: Handle the QRCode result
    [reader stopScanning];
    
    switch (reader.QRCodeType) {
        case QRCodeTypeEnrollment:
            [self enrollWithQRCode:result];
            break;
        case QRCodeTypeOnlineAuth:
            [self approveAuthWithQRCode:result];
            break;
        case QRCodeTypeOfflineAuth:
            [self offlineAuthWithQRCode:result];
            break;
        case QRCodeTypeGeneric:
            [self handleGeneric:result];
            break;
    }
}

- (void)enrollWithQRCode:(NSString *)QRCodeResult
{
    if(self.enrollWithPin){
        __weak __typeof(self) weakSelf = self;
        
        PinViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinViewController"];
        [vc setPinModeWithMode:@"set"];
        [vc setDidFinishWithPinWithCallback:^(NSString * _Nullable pin) {
            [FTRClient.sharedClient enrollAndSetupSDKPin:pin code:QRCodeResult callback:^(NSError * _Nullable error) {
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    if (error) {
                        [self _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                        return;
                    }
                    
                    [weakSelf _showAlertWithTitle:@"Success" message:@"User account enrolled successfully!"];
                }];
            }];
        }];
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:vc animated:true completion:nil];
        }];
        
    } else {
        [FTRClient.sharedClient enroll:QRCodeResult callback:^(NSError *error) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    [self _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                    return;
                }
                
                [self _showAlertWithTitle:@"Success" message:@"User account enrolled successfully!"];
            }];
        }];
    }
}

- (void)approveAuthWithQRCode:(NSString *)QRCodeResult
{
    [FTRClient.sharedClient approveAuthWithQrCode:QRCodeResult callback:^(NSError * _Nullable error) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (error) {
                [self _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                return;
            }
            [self _showAlertWithTitle:@"Success" message:@"User authenticated successfully!"];
        }];
    }];
}

- (void)offlineAuthWithQRCode:(NSString *)QRCodeResult
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([FTRClient QRCodeTypeFromQRCode:QRCodeResult] == FTRQRCodeTypeOfflineAuth) {
            [self showApproveOfflineAlertQRCode: QRCodeResult];
        } else {
            [self _showAlertWithTitle:@"Error" message:@"QR Code type is not offline."];
        }
    }];
}

- (void)handleGeneric:(NSString *)QRCodeResult
{
    switch ([FTRClient QRCodeTypeFromQRCode:QRCodeResult]) {
        case FTRQRCodeTypeEnrollment:
            [self enrollWithQRCode:QRCodeResult];
            break;
        case FTRQRCodeTypeOnlineAuth:
            [self approveAuthWithQRCode:QRCodeResult];
            break;
        case FTRQRCodeTypeOfflineAuth:
            [self offlineAuthWithQRCode:QRCodeResult];
            break;
        case FTRQRCodeTypeInvalid:
            [self _showAlertWithTitle:@"Error" message:@"QR Code is invalid."];
            break;
    }
}

- (void)showApproveOfflineAlertQRCode:(NSString *)QRCodeResult
{
    NSArray<FTRExtraInfo *> *extras = [FTRClient.sharedClient extraInfoFromOfflineQRCode:QRCodeResult];
    NSMutableString *mutableFormattedExtraInfo = NSMutableString.new;
    for (FTRExtraInfo *extraInfo in extras) {
        [mutableFormattedExtraInfo appendString:extraInfo.key];
        [mutableFormattedExtraInfo appendString:@": "];
        [mutableFormattedExtraInfo appendString:extraInfo.value];
        [mutableFormattedExtraInfo appendString:@"\n"];
    }
    
    NSString *title = @"Approve";
    NSString *message = [NSString stringWithFormat:@"Request Information\n%@", mutableFormattedExtraInfo.copy];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Deny" style:UIAlertActionStyleDestructive handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Approve" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showOfflineQRCodeSignatureAlert:QRCodeResult];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showOfflineQRCodeSignatureAlert:(NSString *)QRCodeResult
{
    NSError *error;
    if(operationWithBiometrics){
        operationWithBiometrics = NO;
        __weak __typeof(self) weakSelf = self;
        [[FTRClient sharedClient] computeVerificationCodeFromQRCodeWithBiometrics:QRCodeResult callback:^(NSError * _Nullable err, NSString * _Nullable signature) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showOfflineQRCodeSignatureAlert:signature error:err];
            });
        } promptReason:@"Unlock SDK"];
    } else {
        NSString *signature = [FTRClient.sharedClient computeVerificationCodeFromQRCode:QRCodeResult SDKPin: offlineQRCodePin error:&error];
        offlineQRCodePin = nil;
        [self showOfflineQRCodeSignatureAlert:signature error:error];
    }
}

- (void)showOfflineQRCodeSignatureAlert:(NSString *)signature error: (NSError *)error {
    NSString *title;
    NSString *message;
    if (error) {
        title = @"Error";
        message = error.userInfo[FTRClientErrorUserInfoKey];
        [self _showAlertWithTitle:@"Error" message:message];
    } else {
        title = @"Confirm Transaction";
        message = [NSString stringWithFormat:@"To Approve the transaction, enter: %@ in the browser", signature];
    }
    
    [self _showAlertWithTitle:title message:message];
}

- (void)presentQRCodeControllerWithQRCodeType:(QRCodeType)QRCodeType sender:(UIButton *)sender
{
    NSString *title = [sender titleForState:UIControlStateNormal];
    FTRQRCodeViewController *qrcodeVC = [[FTRQRCodeViewController alloc] initWithTitle:title QRCodeType:QRCodeType];
    qrcodeVC.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:qrcodeVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Alerts
////////////////////////////////////////////////////////////////////////////////
- (void)_showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

@end
