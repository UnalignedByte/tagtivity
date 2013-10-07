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
#import "ChooseActivityElement.h"
#import "SettingsElement.h"
#import "AddActivityElement.h"
#import "SliceElement.h"

#import "Utils.h"


@interface ActivityView ()

@property (nonatomic, strong) Activity *currentActivity;
@property (nonatomic, strong) ChooseActivityElement *chooseActivityElement;
@property (nonatomic, strong) NSMutableArray *activityElements;
@property (nonatomic, strong) SettingsElement *settingsElement;
@property (nonatomic, strong) AddActivityElement *addActivityElement;
@property (nonatomic, strong) SliceElement *sliceElement;

@property (nonatomic, assign) BOOL isShowingCurrentActivity;
@property (nonatomic, assign) BOOL isShowingChooseActivity;
@property (nonatomic, assign) BOOL isShowingSettings;
@property (nonatomic, assign) BOOL isShowingActivityElements;
@property (nonatomic, assign) BOOL isShowingSlicing;

@end


@implementation ActivityView

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame_
{
    if((self = [super initWithFrame:frame_]) == nil)
        return nil;
    
    [self setup];
    
    return self;
}


- (id)initWithCoder:(NSCoder *)coder_
{
    if((self = [super initWithCoder:coder_]) == nil)
        return nil;
    
    [self setup];
    
    return self;
}


- (void)setup
{
    CADisplayLink *redrawTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(redrawTimerFired:)];
    [redrawTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}


#pragma mark - Drawing
- (void)redrawTimerFired:(CADisplayLink *)animationDisplayLink_
{
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect_
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //we change the default coordinates to the same as in OS X (from left and from bottom)
    //because by default on iOS Y is flipped and it causes issues
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    //CGContextTranslateCTM(ctx, 0.0, -self.frame.size.height);
    
    if(self.isShowingCurrentActivity)
        [self drawCurrentActivityInContext:ctx];
    
    if(self.isShowingChooseActivity)
        [self drawChooseActivityInContext:ctx];
    
    if(self.isShowingActivityElements)
        [self drawActivityElementsInContext:ctx];
    
    if(self.isShowingSettings)
        [self drawSettingsInContext:ctx];
    
    if(self.isShowingSlicing)
        [self drawSlicingInContext:ctx];
}


- (void)drawCurrentActivityInContext:(CGContextRef)ctx_
{
    CGRect nameRect = CGRectMake(0.0, 20.0, [Utils viewSize].width, 40.0);
    [self.currentActivity.name drawInRect:nameRect withFont:[UIFont systemFontOfSize:12.0] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}


- (void)drawChooseActivityInContext:(CGContextRef)ctx_
{
    [self.chooseActivityElement drawInContext:ctx_];
}


- (void)drawActivityElementsInContext:(CGContextRef)ctx_
{
    for(ActivityElement *activityElement in self.activityElements) {
        [activityElement drawInContext:ctx_];
    }
}


- (void)drawSettingsInContext:(CGContextRef)ctx_
{
    [self.settingsElement drawInContext:ctx_];
    [self.addActivityElement drawInContext:ctx_];
}


- (void)drawSlicingInContext:(CGContextRef)ctx_
{
    [self.sliceElement drawInContext:ctx_];
}


#pragma mark - Control
- (void)redraw
{
    [self setNeedsDisplay];
}


- (void)showCurrentActivity:(Activity *)activity_ chooseActivityElement:(ChooseActivityElement *)chooseActivityElement_
                   finished:(void (^)())block_
{
    self.currentActivity = activity_;
    self.chooseActivityElement = chooseActivityElement_;
    
    self.isShowingCurrentActivity = YES;
    self.isShowingChooseActivity = YES;
    self.isShowingSettings = NO;
    self.isShowingActivityElements = NO;
    
    [self setNeedsDisplay];
    
    block_();
}


- (void)showActivityElements:(NSMutableArray *)activityElements_ finished:(void (^)())block_
{
    self.activityElements = activityElements_;
    
    self.isShowingCurrentActivity = NO;
    self.isShowingChooseActivity = NO;
    self.isShowingSettings = NO;
    self.isShowingActivityElements = YES;
    
    [self setNeedsDisplay];
    
    block_();
}


- (void)showSettings:(SettingsElement *)settingsElement_ addActivityElement:(AddActivityElement *)addActivityElement_
        sliceElement:(SliceElement *)sliceElement_ finished:(void (^)())block_;
{
    self.settingsElement = settingsElement_;
    self.addActivityElement = addActivityElement_;
    self.sliceElement = sliceElement_;
    
    self.isShowingCurrentActivity = NO;
    self.isShowingChooseActivity = NO;
    self.isShowingSettings = YES;
    self.isShowingActivityElements = YES;
    self.isShowingSlicing = YES;
    
    [self setNeedsDisplay];
    
    block_();
}


- (void)showSlicing:(SliceElement *)sliceElement_
{
    self.sliceElement = sliceElement_;
}


- (void)moveActivityElementsToNewAngle:(NSArray *)activityElements_
{
    for(ActivityElement *activityElement in activityElements_) {
        
        [Utils animateValueFrom:activityElement.angle to:activityElement.newAngle duration:0.5 block:^(double value) {
            activityElement.angle = value;
        }];
    }
}

@end
