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
    FTRQRCodeViewController *qrcodeVC = [[FTRQRCodeViewController alloc] init];
    qrcodeVC.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:qrcodeVC];
    [self presentViewController:navigationController animated:YES completion:nil];
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
- (IBAction)qrCodeTouchedUpInside:(UIButton *)sender
{
    FTRQRCodeViewController *qrcodeVC = [[FTRQRCodeViewController alloc] init];
    qrcodeVC.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:qrcodeVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////////////
- (IBAction)totpTouchedUpInside:(UIButton *)sender
{
    FTRAccount *account = [[FTRClient sharedClient] getAccounts].firstObject;
    FTRTotp *totp = [[FTRClient sharedClient] nextTotpForUser:account.user_id];
    
    NSString *title = @"TOTP";
    NSString *body = [NSString stringWithFormat:@"Code: %@ (remaining: %@ sec)", totp.totp, totp.remaining_secs];
    [self _showAlertWithTitle:title message:body];
}

#pragma mark - FTRQRCodeReaderDelegate
////////////////////////////////////////////////////////////////////////////////
- (void)reader:(FTRQRCodeViewController * _Nullable)reader didScanResult:(NSString *_Nullable)result
{
    // TODO: Handle the QRCode result
    [reader stopScanning];
    
    NSArray *comps = [result componentsSeparatedByString:@":"];
    if (comps.count == 1) {
        // Handle enrollment
        [[FTRClient sharedClient] enroll:result callback:^(NSError *error) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                if (error) {
                    [self _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                    return;
                }
                
                [self _showAlertWithTitle:@"Success" message:@"User account enrolled successfully!"];
            }];
        }];
    }
    if (comps.count == 2) {
        // Handle authentication
        [[FTRClient sharedClient] approveAuthWithQrCode:result
                                                   callback:^(NSError * _Nullable error) {
                                                       [self dismissViewControllerAnimated:YES completion:^{
                                                           if (error) {
                                                               [self _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                                                               return;
                                                           }
                                                           [self _showAlertWithTitle:@"Success" message:@"User authenticated successfully!"];
                                                            }];
                                                        }];
    }
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
