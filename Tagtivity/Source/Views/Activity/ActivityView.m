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

@property (nonatomic, assign) bool isShowingCurrentActivity;
@property (nonatomic, assign) bool isShowingActivityElements;

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
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0.0, -self.frame.size.height);
    
    if(self.isShowingCurrentActivity)
        [self drawCurrentActivity:self.currentActivity context:ctx];
    
    if(self.isShowingActivityElements)
        [self drawActivityElements:self.activityElements context:ctx];
}


- (void)drawCurrentActivity:(Activity *)activity_ context:(CGContextRef)ctx_
{
    CGContextSelectFont(ctx_, "Arial", 24, kCGEncodingMacRoman);
    CGContextShowTextAtPoint(ctx_, 10.0, 0.0, "hello", 5);
}


- (void)drawActivityElements:(NSArray *)activityElements_ context:(CGContextRef)ctx_
{
}


#pragma mark - Control
- (void)showCurrentActivity:(Activity *)activity_ finished:(void (^)())block_
{
    self.isShowingCurrentActivity = YES;
    [self setNeedsDisplay];
}


- (void)hideCurrentActivity:(void (^)())block_
{
    
}


- (void)showActivityElements:(NSArray *)activityElements_ finished:(void (^)())block_
{
    
}


- (void)hideActivityElements:(void (^)())block_
{
    
}

@end
