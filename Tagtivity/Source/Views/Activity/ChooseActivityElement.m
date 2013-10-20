//
//  ChooseActivityElement.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 12.07.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ChooseActivityElement.h"

#import "Utils.h"


#define DIAMETER 80.0


@interface ChooseActivityElement ()

@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) CGFloat drawDiameter;
@property (nonatomic, assign) CGFloat drawAlpha;

@end


@implementation ChooseActivityElement

#pragma mark - Initialization
- (id)init
{
    if((self = [super init]) == nil)
        return nil;
    
    _circleCenter = CGPointMake([Utils viewSize].width/2.0, [Utils viewSize].height/2.0);
    self.isVisible = NO;
    
    [self animateOut];
    
    return self;
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    CGRect circleRect = CGRectMake(_circleCenter.x - self.drawDiameter/2.0,
                                   _circleCenter.y - self.drawDiameter/2.0,
                                   self.drawDiameter, self.drawDiameter);
    
    CGFloat gradientLocations[] = {0.6, 1.0};
    NSArray *gradientColors = @[//(id)[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.0].CGColor,
                                //(id)[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0].CGColor,
                                (id)[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:self.drawAlpha].CGColor,
                                (id)[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.0].CGColor];
    /*NSArray *gradientColors = @[(id)[UIColor colorWithRed:0.95 green:0.50 blue:0.50 alpha:0.0].CGColor,
                                (id)[UIColor colorWithRed:0.95 green:0.50 blue:0.50 alpha:0.1].CGColor,
                                (id)[UIColor colorWithRed:0.95 green:0.50 blue:0.50 alpha:0.1].CGColor,
                                (id)[UIColor colorWithRed:0.95 green:0.50 blue:0.50 alpha:0.0].CGColor];*/
    CGGradientRef pulseGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //CGContextSetStrokeColorWithColor(ctx_, [UIColor redColor].CGColor);
    //CGContextSetLineWidth(ctx_, 4.0);
    //CGContextStrokeEllipseInRect(ctx_, circleRect);
    CGContextAddEllipseInRect(ctx_, circleRect);
    //CGContextDrawLinearGradient(ctx_, pulseGradient, 0.0, 1.0, 0);
    CGContextDrawRadialGradient(ctx_, pulseGradient,
                                _circleCenter, 0.0,
                                _circleCenter, self.drawDiameter,
                                0);
}


#pragma mark - Control
- (void)show
{
    if(self.isVisible)
        return;
    
    self.isVisible = YES;
    
    self.drawAlpha = 0.0;
    [Utils animateValueFrom:0.0 to:1.0 duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawAlpha = value;
    }];
}

- (void)animateOut
{
    [Utils animateValueFrom:0.5 to:1.0 duration:3.0 curve:AnimationCurveElasticInOut block:^(double value) {
        self.drawDiameter = DIAMETER*value;
        if(value == 1.0) {
            [[NSRunLoop mainRunLoop] performSelector:@selector(animateIn) target:self argument:Nil order:0 modes:@[NSRunLoopCommonModes]];
        }
    }];
}


- (void)animateIn
{
    [Utils animateValueFrom:1.0 to:0.5 duration:5.0 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawDiameter = DIAMETER*value;
        if(value == 0.5) {
            [[NSRunLoop mainRunLoop] performSelector:@selector(animateOut) target:self argument:Nil order:0 modes:@[NSRunLoopCommonModes]];
        }
    }];
}


- (void)hide
{
    if(!self.isVisible)
        return;
    
    [Utils animateValueFrom:self.drawAlpha to:0.0 duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawAlpha = value;
        if(value == 0)
            self.isVisible = NO;
    }];
}


#pragma mark - Input
- (BOOL)isTouching:(CGPoint)touchLocation_
{
    CGFloat distance = [Utils distanceBetweenPointA:touchLocation_ pointB:_circleCenter];
    if(distance <= DIAMETER/2.0)
        return YES;
    
    return NO;
}

@end
