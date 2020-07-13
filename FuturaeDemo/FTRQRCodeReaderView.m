//
//  FTRQRCodeView.m
//  FuturaeDemo
//
//  Created by Dimitris Togias on 22/01/2018.
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and Confidential.
//
//  Copyright (C) 2017 Futurae Technologies AG - All rights reserved.
//  For any inquiry, contact: legal@futurae.com
//

#import "FTRQRCodeReaderView.h"

////////////////////////////////////////////////////////////////////////////////
@interface FTRQRCodeReaderView ()
{
    CAShapeLayer *_overlay;
}

@end

////////////////////////////////////////////////////////////////////////////////
@implementation FTRQRCodeReaderView

#pragma mark - Initialization
////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) {
        return nil;
    }
    
    [self _addOverlay];
    
    return self;
}

#pragma mark - Overrides
////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect
{
    CGRect innerRect = CGRectInset(rect, 50, 50);
    
    CGFloat minSize = MIN(innerRect.size.width, innerRect.size.height);
    if (innerRect.size.width != minSize) {
        innerRect.origin.x += (innerRect.size.width - minSize) / 2;
        innerRect.size.width = innerRect.size.height + fmodf(minSize, 2);
        innerRect.size.height = minSize;
    }
    else if (innerRect.size.height != minSize) {
        innerRect.origin.y += (innerRect.size.height - minSize) / 2;
        innerRect.size.height = minSize + fmodf(minSize, 2);
        innerRect.size.width = innerRect.size.height;
    }
    
    CGRect offsetRect = CGRectOffset(innerRect, 0, 15);
    
    NSNumber *cornerWidth = @(50.0);
    NSNumber *cornerSpace = @(offsetRect.size.width - 100.0f);
    
    _overlay.lineDashPattern = @[cornerWidth, cornerSpace,
                                 cornerWidth, @0,
                                 cornerWidth, cornerSpace,
                                 cornerWidth, @0,
                                 cornerWidth, cornerSpace,
                                 cornerWidth, @0,
                                 cornerWidth, cornerSpace,
                                 cornerWidth];
    
    _overlay.path = [UIBezierPath bezierPathWithRect:offsetRect].CGPath;
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////
- (void)_addOverlay
{
    _overlay = [[CAShapeLayer alloc] init];
    _overlay.backgroundColor = [UIColor clearColor].CGColor;
    _overlay.fillColor = [UIColor clearColor].CGColor;
    _overlay.strokeColor = [UIColor colorWithWhite:1.0f alpha:0.6f].CGColor;
    _overlay.lineWidth = 6;
    _overlay.lineCap = kCALineCapSquare;
    
    [self.layer addSublayer:_overlay];
}


@end
