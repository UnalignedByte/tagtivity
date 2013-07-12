//
//  ActivityView.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 18.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ActivityView.h"

#import "Activity.h"
#import "ActivityElement.h"


@interface ActivityView ()

@property (nonatomic, assign) BOOL isShowingCurrentActivity;
@property (nonatomic, assign) BOOL isShowingActivityElements;
@property (nonatomic, assign) BOOL isShowingSettings;

@property (nonatomic, strong) Activity *currentActivity;
@property (nonatomic, strong) NSArray *activityElements;

@end


@implementation ActivityView

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect_
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //we change the default coordinates to the same as in OS X (from left and from bottom)
    //because by default on iOS Y is flipped and it causes issues
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    //CGContextTranslateCTM(ctx, 0.0, -self.frame.size.height);
    
    if(self.isShowingCurrentActivity)
        [self drawCurrentActivity:self.currentActivity context:ctx];
    
    if(self.isShowingSettings)
        [self drawSettingsInContext:ctx];
    
    if(self.isShowingActivityElements)
        [self drawActivityElements:self.activityElements context:ctx];
}


- (void)drawCurrentActivity:(Activity *)activity_ context:(CGContextRef)ctx_
{
    //CGContextSelectFont(ctx_, "Arial", 24, kCGEncodingMacRoman);
    //CGContextShowTextAtPoint(ctx_, 10.0, 0.0, "hello", 5);
    CGRect nameRect = CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, 40.0);
    [activity_.name drawInRect:nameRect withFont:[UIFont systemFontOfSize:12.0] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    CGRect circleRect = CGRectMake(self.chooseNewActivityCircleCenter.x - self.chooseNewActivityCircleDiameter/2.0,
                                   self.chooseNewActivityCircleCenter.y - self.chooseNewActivityCircleDiameter/2.0,
                                   self.chooseNewActivityCircleDiameter,
                                   self.chooseNewActivityCircleDiameter);
    CGContextSetStrokeColorWithColor(ctx_, [UIColor redColor].CGColor);
    CGContextSetLineWidth(ctx_, 4.0);
    CGContextStrokeEllipseInRect(ctx_, circleRect);
}


- (void)drawSettingsInContext:(CGContextRef)ctx_
{
    CGRect circleRect = CGRectMake(self.chooseNewActivityCircleCenter.x - self.chooseNewActivityCircleDiameter/4.0,
                                   self.chooseNewActivityCircleCenter.y - self.chooseNewActivityCircleDiameter/4.0,
                                   self.chooseNewActivityCircleDiameter/2.0,
                                   self.chooseNewActivityCircleDiameter/2.0);
    CGContextSetStrokeColorWithColor(ctx_, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(ctx_, 2.0);
    CGContextStrokeEllipseInRect(ctx_, circleRect);
}


- (void)drawActivityElements:(NSArray *)activityElements_ context:(CGContextRef)ctx_
{
    for(ActivityElement *activityElement in activityElements_)
        [activityElement drawInContext:ctx_];
}


#pragma mark - Control
- (void)showCurrentActivity:(Activity *)activity_ finished:(void (^)())block_
{
    self.currentActivity = activity_;
    self.isShowingCurrentActivity = YES;
    self.isShowingActivityElements = NO;
    self.isShowingSettings = NO;
    
    [self setNeedsDisplay];
    
    block_();
}


- (void)showActivityElements:(NSArray *)activityElements_ finished:(void (^)())block_
{
    self.activityElements = activityElements_;
    self.isShowingCurrentActivity = NO;
    self.isShowingActivityElements = YES;
    
    [self setNeedsDisplay];
    
    block_();
}


- (void)showSettings:(void (^)())block_
{
    self.isShowingCurrentActivity = NO;
    self.isShowingSettings = YES;
    self.isShowingActivityElements = YES;
    
    [self setNeedsDisplay];
    
    block_();
}

@end
