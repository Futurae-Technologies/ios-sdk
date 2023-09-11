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
#import "HistoryItem.h"

////////////////////////////////////////////////////////////////////////////////
@interface ViewController () <FTRQRCodeReaderDelegate>
{
    NSDateFormatter *_rfc2882DateFormatter;
}

@end

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
@interface ViewController () <FTRAdaptiveSDKDelegate>
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
    
    [self loadServiceLogo];
}

- (void)loadServiceLogo {
    if(!FTRClient.sdkIsLaunched){
        return;
    }
    
    FTRAccount *account = [[FTRClient sharedClient] getAccounts].firstObject;
    if (account == nil || account.service_logo == nil || [account.service_logo isKindOfClass:[NSNull class]]) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    NSURL *url = [[NSURL alloc] initWithString:account.service_logo];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage* image = [[UIImage alloc]initWithData:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.serviceLogoImageView setImage:image];
        });
    });
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

- (IBAction)enrollShortCodeTouchedUpInside:(UIButton *)sender
{
    [self enrollShortCodeWithPin:NO];
}

- (IBAction)enrollShortCodeWithPinTouchedUpInside:(UIButton *)sender
{
    [self enrollShortCodeWithPin:YES];
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
            [self _showAlertWithTitle:@"Success" message:[NSString stringWithFormat:@"Logged out user %@", account.username ? account.username : @"Username N/A"]];
        }
    }];
}

////////////////////////////////////////////////////////////////////////////////
- (IBAction)forceDeleteAccountTouchedUpInside:(UIButton *)sender
{
    // For demo purposes we simply delete the first account we can find
    FTRAccount *account = [[FTRClient sharedClient] getAccounts].firstObject;
    if (account == nil) {
        [self _showAlertWithTitle:@"Error" message:@"No user enrolled"];
        return;
    }
    
    [[FTRClient sharedClient] deleteAccount:account.user_id callback:^(NSError * _Nullable error) {
        if (error) {
            [self _showAlertWithTitle:@"Error" message: error.userInfo[@"msg"] ? error.userInfo[@"msg"] : error.localizedDescription];
        } else {
            [self _showAlertWithTitle:@"Success" message:[NSString stringWithFormat:@"Deleted user_id %@", account.user_id]];
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
    [vc setPinMode:@"set"];
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
    [vc setPinMode:@"set"];
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
            if(err){
                [weakSelf _showAlertWithTitle:@"Error" message:err.userInfo[@"msg"]];
                return;
            } else {
                NSString *title = @"TOTP";
                NSString *body = [NSString stringWithFormat:@"Code: %@ (remaining: %@ sec)", totp.totp, totp.remaining_secs];
                [weakSelf _showAlertWithTitle:title message:body];
            }
            
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

- (IBAction)syncTokenTouchedUpInside:(UIButton *)sender
{
    __weak __typeof(self) weakSelf = self;
    FTRAccount *account = [[FTRClient sharedClient] getAccounts].firstObject;
    [[FTRClient sharedClient] synchronousAuthTokenForUser:account.user_id callback:^(NSError * _Nullable error, NSString * _Nullable token) {
        if (error) {
            [weakSelf _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
            return;
        }
        
        NSString *title = @"Sync Auth Token";
        UIPasteboard.generalPasteboard.string = token;
        [weakSelf _showAlertWithTitle:title message:token];
    }];
}

- (IBAction)scanQRCodeTouchedUpInside:(UIButton *)sender
{
    [self presentQRCodeControllerWithQRCodeType:QRCodeTypeGeneric sender:sender];
}

- (IBAction)scanQRCodeWithPINTouchedUpInside:(id)sender {
    __weak __typeof(self) weakSelf = self;
    
    PinViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinViewController"];
    [vc setPinMode:@"set"];
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
    [FTRClient.sharedClient checkMigratableAccountsSuccess:^(FTRMigrationCheckData *data) {
        NSString *title = [NSString stringWithFormat:@"Number of accounts to migrate: %lu",
                           (unsigned long)data.numberOfAccountsToMigrate];
        
        NSMutableString *string = NSMutableString.new;
        for (FTRMigratableAccount *acc in data.migratableAccounts) {
            [string appendString: acc.username];
            [string appendString:@"\n"];
        }
        [string appendString:[NSString stringWithFormat:@"Pin protected: %s \n", data.pinProtected ? "true" : "false"]];
        [string appendString:[NSString stringWithFormat:@"Adaptive migration enabled: %s \n", data.adaptiveMigrationEnabled ? "true" : "false"]];
        
        NSString *message = string;
        [weakSelf _showAlertWithTitle:title message:message];
        [weakSelf loadServiceLogo];
    } failure:^(NSError * _Nonnull error) {
        NSString *title = @"Checking account migration failed";
        NSString *message = [error.userInfo.allValues componentsJoinedByString:@", "];
        [weakSelf _showAlertWithTitle:title message:message];
    }];
}

- (IBAction)executeAccountMigrationTouchedUpInside:(UIButton *)sender
{
    [self executeAccountMigrationWithSDKPin:nil];
}

- (IBAction)executeAccountMigrationWithPinTouchedUpInside:(UIButton *)sender
{
    __weak __typeof(self) weakSelf = self;
    
    PinViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinViewController"];
    [vc setPinMode:@"input"];
    [vc setDidFinishWithPinWithCallback:^(NSString * _Nullable pin) {
        [self executeAccountMigrationWithSDKPin:pin];
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf presentViewController:vc animated:true completion:nil];
    }];
}

-(void)executeAccountMigrationWithSDKPin:(NSString * _Nullable)SDKPin {
    __weak __typeof(self) weakSelf = self;
    [FTRClient.sharedClient executeAccountMigrationWithSDKPin:SDKPin success:^(NSArray<FTRAccount *> * _Nonnull accountsMigrated) {
        NSString *title = @"Executing account migration succeeds";
        NSArray<NSString *> *usernames = [accountsMigrated map:^NSString *_Nonnull(FTRAccount *account) {
            return account.username ? account.username : @"Username N/A";
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

- (IBAction)fetchAccountHistory:(UIButton *)sender {
    FTRAccount *account = [[FTRClient sharedClient] getAccounts].firstObject;
    __weak __typeof(self) weakSelf = self;
    [FTRClient.sharedClient getAccountHistory:account success:^(id responseObject) {
        NSArray<HistoryItem *> *allItems = [weakSelf historyItemsFromResponse:responseObject];
        HistoryTableViewController *vc = [[HistoryTableViewController alloc] initWithAccount:account items:allItems];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nc animated:YES completion:nil];
    }
    failure:^(NSError * _Nullable error) {
        NSString *title = @"Fetch account history failed";
        NSString *message = [error.userInfo.allValues componentsJoinedByString:@", "];
        [weakSelf _showAlertWithTitle:title message:message];
    }];
}

- (IBAction)getAccountsStatus:(UIButton *)sender {
    NSArray<FTRAccount *> *accounts = [[FTRClient sharedClient] getAccounts];
    __weak __typeof(self) weakSelf = self;
    [FTRClient.sharedClient getAccountsStatus:accounts success:^(id responseObject) {
        [weakSelf _showAlertWithTitle:@"Accounts status" message:[NSString stringWithFormat:@"%@", responseObject]];
    }
    failure:^(NSError * _Nullable error) {
        NSString *title = @"Error";
        NSString *message = [error.userInfo.allValues componentsJoinedByString:@", "];
        [weakSelf _showAlertWithTitle:title message:message];
    }];
}

- (IBAction)adaptiveCollections:(UIButton *)sender {
    AdaptiveViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdaptiveViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)enableAdaptive:(UIButton *)sender {
    [FTRClient.sharedClient enableAdaptiveWithDelegate:self];
    [_enableAdaptiveButton setHidden:YES];
    [_disableAdaptiveButton setHidden:NO];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"adaptive_enabled"];
}

- (IBAction)disableAdaptive:(UIButton *)sender {
    [FTRClient.sharedClient disableAdaptive];
    [_enableAdaptiveButton setHidden:NO];
    [_disableAdaptiveButton setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"adaptive_enabled"];
}

- (IBAction)validateAttestation:(UIButton *)sender {
    if (@available(iOS 14.0, *)) {
        __weak __typeof(self) weakSelf = self;
        [FTRClient.sharedClient appAttestation:@"T82Z6CGNMT.com.futurae.FuturaeDemo"
                                    production: NO
                                      callback:^(NSError*  _Nullable error) {
            NSLog(@"%@", error);
            [weakSelf _showAlertWithTitle:error ? @"Attestation failed" : @"Attestation success"
                                  message: (error && error.userInfo[@"message"]) ? error.userInfo[@"message"] : @"App integrity verified"];
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (IBAction)jailbreakStatus:(UIButton *)sender {
    JailbreakStatus *status = FTRClient.sharedClient.jailbreakStatus;
    [self _showAlertWithTitle:status.jailbroken ? @"Device is jailbroken" : @"Jailbreak not detected" message: status.message ? status.message : @""];
}

- (IBAction)updateAppGroup:(UIButton *)sender {
    __weak __typeof(self) weakSelf = self;
    [FTRClient.sharedClient updateSDKConfigWithAppGroup: SDKConstants.APP_GROUP
                                           keychainConfig:[FTRKeychainConfig configWithAccessGroup:SDKConstants.APP_GROUP]
                                                 callback:^(NSError * _Nullable error) {
        [weakSelf _showAlertWithTitle: error ? @"Failed to update" : @"App group updated" message: @""];
        if(!error){
            [[[NSUserDefaults alloc] initWithSuiteName:SDKConstants.APP_GROUP] setBool:YES forKey:@"app_group_enabled"];
        }
    }];
}

- (IBAction)removeAppGroup:(UIButton *)sender {
    __weak __typeof(self) weakSelf = self;
    [FTRClient.sharedClient updateSDKConfigWithAppGroup: nil
                                           keychainConfig:nil
                                                 callback:^(NSError * _Nullable error) {
        [weakSelf _showAlertWithTitle: error ? @"Failed to remove" : @"App group removed" message: @""];
        if(!error){
            [[[NSUserDefaults alloc] initWithSuiteName:SDKConstants.APP_GROUP] setBool:NO forKey:@"app_group_enabled"];
        }
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
    __weak __typeof(self) weakSelf = self;
    if(self.enrollWithPin){
        PinViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinViewController"];
        [vc setPinMode:@"set"];
        [vc setDidFinishWithPinWithCallback:^(NSString * _Nullable pin) {
            [FTRClient.sharedClient enrollAndSetupSDKPin:pin code:QRCodeResult callback:^(NSError * _Nullable error) {
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    if (error) {
                        [self _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                        return;
                    }
                    
                    [weakSelf _showAlertWithTitle:@"Success" message:@"User account enrolled successfully!"];
                    [weakSelf loadServiceLogo];
                }];
            }];
        }];
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:vc animated:true completion:nil];
        }];
        
    } else {
        [FTRClient.sharedClient enroll:QRCodeResult callback:^(NSError *error) {
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    [weakSelf _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                    return;
                }
                
                [weakSelf _showAlertWithTitle:@"Success" message:@"User account enrolled successfully!"];
                [weakSelf loadServiceLogo];
            }];
        }];
    }
}

- (void)enrollShortCodeWithPin:(BOOL)withPin {
    __weak __typeof(self) weakSelf = self;
    PinViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinViewController"];
    [vc setPinLength: 19];
    [vc setSecureText:NO];
    [vc setPinMode:@"shortCode"];
    [vc setDidFinishWithPinWithCallback:^(NSString * _Nullable pin) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [weakSelf enrollWithShortCode:pin enrollWithPin:withPin];
        }];
    }];
    
    [self presentViewController:vc animated:true completion:nil];
}

- (void)enrollWithShortCode:(NSString *)code enrollWithPin:(BOOL)withPin
{
    __weak __typeof(self) weakSelf = self;
    
    if(withPin){
        PinViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pinViewController"];
        [vc setPinMode:@"set"];
        [vc setDidFinishWithPinWithCallback:^(NSString * _Nullable pin) {
            [FTRClient.sharedClient enrollAndSetupSDKPin:pin activationShortCode:code callback:^(NSError * _Nullable error) {
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    if (error) {
                        [weakSelf _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                        return;
                    }
                    
                    [weakSelf _showAlertWithTitle:@"Success" message:@"User account enrolled successfully!"];
                    [weakSelf loadServiceLogo];
                }];
            }];
        }];
        
        [self presentViewController:vc animated:true completion:nil];
        
    } else {
        [FTRClient.sharedClient enrollWithActivationShortCode:code callback:^(NSError *error) {
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    [weakSelf _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                    return;
                }
                
                [weakSelf _showAlertWithTitle:@"Success" message:@"User account enrolled successfully!"];
                [weakSelf loadServiceLogo];
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

- (void)approveAuthWithUsernamelessQRCode:(NSString *)QRCodeResult
{
    NSArray<FTRAccount *> *accounts = FTRClient.sharedClient.getAccounts;
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Usernameless QR code"
                                                                message:@"Select an account"
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak __typeof(self) weakSelf = self;
    for (FTRAccount *account in accounts) {
        [ac addAction:[UIAlertAction actionWithTitle:account.username ? account.username : @"Username N/A" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf approveAuthWithUsernamelessQRCode:QRCodeResult userId:account.user_id];
        }]];
    }
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf presentViewController:ac animated:true completion:nil];
    }];
    
    
}

- (void)approveAuthWithUsernamelessQRCode:(NSString *)QRCodeResult userId: (NSString *)userId {
    __weak __typeof(self) weakSelf = self;
    [FTRClient.sharedClient approveAuthWithUsernamelessQrCode:QRCodeResult userId: userId callback:^(NSError * _Nullable error) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (error) {
                [self _showAlertWithTitle:@"Error" message:error.userInfo[@"msg"]];
                return;
            }
            [weakSelf _showAlertWithTitle:@"Success" message:@"User authenticated successfully!"];
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
        case FTRQRCodeTypeUsernameless:
            [self approveAuthWithUsernamelessQRCode:QRCodeResult];
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
            [weakSelf showOfflineQRCodeSignatureAlert:signature error:err];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    });
}

- (NSArray<HistoryItem *> *)historyItemsFromResponse:(id)response {
    NSMutableArray<HistoryItem *> *allItems = NSMutableArray.new;
    for (NSDictionary *accountHistory in response[@"activity"]) {
        [allItems addObject:[[HistoryItem alloc] initFromAccountHistory:accountHistory]];
    }

    return allItems.copy;
}

- (FTRAdaptivePermissionStatus)bluetoothPermissionStatus {
    return FTRAdaptivePermissionStatusOn;
}

- (FTRAdaptivePermissionStatus)bluetoothSettingStatus {
    return FTRAdaptivePermissionStatusOn;
}

- (FTRAdaptivePermissionStatus)locationPermissionStatus {
    return FTRAdaptivePermissionStatusOn;
}

- (FTRAdaptivePermissionStatus)locationPrecisePermissionStatus {
    return FTRAdaptivePermissionStatusOn;
}

- (FTRAdaptivePermissionStatus)locationSettingStatus {
    return FTRAdaptivePermissionStatusOn;
}

- (FTRAdaptivePermissionStatus)networkPermissionStatus {
    return FTRAdaptivePermissionStatusOn;
}

- (FTRAdaptivePermissionStatus)networkSettingStatus {
    return FTRAdaptivePermissionStatusOn;
}

- (void)didReceiveUpdateWithCollectedData:(NSDictionary<NSString *,id> *)collectedData {
    [AdaptiveDebugStorage.shared save:collectedData];
}

@end
