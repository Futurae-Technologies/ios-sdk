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

////////////////////////////////////////////////////////////////////////////////
@interface ViewController () <FTRQRCodeReaderDelegate>
{
    NSDateFormatter *_rfc2882DateFormatter;
}

@end

////////////////////////////////////////////////////////////////////////////////
@implementation ViewController

#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *accounts = [[FTRClient sharedClient] getAccounts];
    if (accounts != nil && accounts.count > 0) {
        [[FTRClient sharedClient] getAccountsStatus:accounts
                                                success:^(id _Nullable data) {
                                                    NSLog(@"Received accounts status: %@", data);
                                                }
                                                failure:^(NSError * _Nullable error) {
                                                    NSLog(@"Could not get accounts status: %@", error);
                                                }];
    }
}

#pragma mark - Handlers
////////////////////////////////////////////////////////////////////////////////
- (IBAction)enrollTouchedUpInside:(UIButton *)sender
{
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
        if (error) {
            [self _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
            return;
        }
        [self _showAlertWithTitle:@"Success" message:[NSString stringWithFormat:@"Logged out user %@", account.username]];
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

- (IBAction)totpTouchedUpInside:(UIButton *)sender
{
    FTRAccount *account = [[FTRClient sharedClient] getAccounts].firstObject;
    FTRTotp *totp = [[FTRClient sharedClient] nextTotpForUser:account.user_id];
    
    NSString *title = @"TOTP";
    NSString *body = [NSString stringWithFormat:@"Code: %@ (remaining: %@ sec)", totp.totp, totp.remaining_secs];
    [self _showAlertWithTitle:title message:body];
}

- (IBAction)scanQRCodeTouchedUpInside:(UIButton *)sender
{
    [self presentQRCodeControllerWithQRCodeType:QRCodeTypeGeneric sender:sender];
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
    NSString *signature = [FTRClient.sharedClient computeVerificationCodeFromQRCode:QRCodeResult error:&error];
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
