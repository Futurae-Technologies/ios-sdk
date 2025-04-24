//
//  FTRQrCodeViewController.m
//  FuturaeDemo
//
//  Created by Dimitris Togias on 22/01/2018.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2017 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import "FTRQRCodeViewController.h"
#import <FuturaeKit/FuturaeKit.h>

#import "FTRQRCodeReaderView.h"

////////////////////////////////////////////////////////////////////////////////
@interface FTRQRCodeViewController ()
{
    FTRQRCodeReader *_codeReader;
    FTRQRCodeReaderView * _Nullable _cameraView;
}

@end

////////////////////////////////////////////////////////////////////////////////
@implementation FTRQRCodeViewController

#pragma mark - Lifecycle

- (instancetype)initWithTitle:(NSString *)title QRCodeType:(QRCodeType)QRCodeType
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = title;
        self.QRCodeType = QRCodeType;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _codeReader = [FTRQRCodeReader reader];
    [self _setup];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor grayColor];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
}

////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startScanning];
}

////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopScanning];
}

////////////////////////////////////////////////////////////////////////////////
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _codeReader.previewLayer.frame = self.view.bounds;
}

////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - Public

////////////////////////////////////////////////////////////////////////////////
- (void)startScanning
{
    [_codeReader startScanning];
}

////////////////////////////////////////////////////////////////////////////////
- (void)stopScanning
{
    [_codeReader stopScanning];
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////
- (void)_setup
{
    [self _setupUIComponents];
    [self _setupAutoLayoutConstraints];
    
    [_cameraView.layer insertSublayer:_codeReader.previewLayer atIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    
    __weak __typeof__(self) weakSelf = self;
    [_codeReader setCompletionWithBlock:^(NSString *resultAsString) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(reader:didScanResult:)]) {
            [weakSelf.delegate reader:weakSelf didScanResult:resultAsString];
        }
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(_closedPressed)];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_setupUIComponents
{
    _cameraView = [[FTRQRCodeReaderView alloc] init];
    _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    _cameraView.clipsToBounds = YES;
    [self.view addSubview:_cameraView];
    
    [_codeReader.previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    if ([_codeReader.previewLayer.connection isVideoOrientationSupported]) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        _codeReader.previewLayer.connection.videoOrientation = [FTRQRCodeReader videoOrientationFromInterfaceOrientation:orientation];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)_setupAutoLayoutConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_cameraView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cameraView]|" options:0 metrics:nil views:views]];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_orientationChanged:(NSNotification *)notification
{
    [_cameraView setNeedsDisplay];
    
    if (_codeReader.previewLayer.connection.isVideoOrientationSupported) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        _codeReader.previewLayer.connection.videoOrientation = [FTRQRCodeReader videoOrientationFromInterfaceOrientation:orientation];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (IBAction)_closedPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Memory Management
////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
    [self stopScanning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
