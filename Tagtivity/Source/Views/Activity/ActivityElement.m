//
//  ActivityElement.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 24.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ActivityElement.h"

#import "Activity.h"

#import "Utils.h"


#define CIRCLE_DIAMETER 80.0


@interface ActivityElement ()

@property (nonatomic, strong) Activity *activity;
@property (nonatomic, assign) CGPoint circleCenter;
@property (nonatomic, assign) BOOL isVisible;

@property (nonatomic, assign) CGFloat distanceFromCenter;
@property (nonatomic, assign) CGFloat circleDiameter;
@property (nonatomic, assign) CGFloat alpha;

@end


@implementation ActivityElement

#pragma mark - Initialization
- (id)initWithActivity:(Activity *)activity_ angle:(CGFloat)angle_;
{
    if((self = [super init]) == nil)
        return nil;
    
    self.activity = activity_;
    self.angle = angle_;
    //self.circleCenter = [self getCircleCenterFromAngle:self.angle diameter:CIRCLE_DIAMETER];
    self.isVisible = NO;
    
    return self;
}


#pragma mark - Properties
- (void)setAngle:(CGFloat)angle_
{
    _angle = angle_;
    //self.circleCenter = [self getCircleCenterFromAngle:angle_ diameter:CIRCLE_DIAMETER];
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    if(!self.isVisible)
        return;

    const CGFloat *colorComponents = CGColorGetComponents([(UIColor *)self.activity.color CGColor]);
    UIColor *color = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:self.alpha];
    
    CGContextSetFillColorWithColor(ctx_, color.CGColor);
    
    //Draw circle
    CGRect circleRect = CGRectMake(self.circleCenter.x - self.circleDiameter/2.0, self.circleCenter.y - self.circleDiameter/2.0,
                                   self.circleDiameter, self.circleDiameter);
    CGContextFillEllipseInRect(ctx_, circleRect);

    //Draw Name
    CGContextSetFillColorWithColor(ctx_, [UIColor blackColor].CGColor);
    CGRect nameRect = CGRectMake(self.circleCenter.x - CIRCLE_DIAMETER/2.0,
                                 self.circleCenter.y,
                                 self.circleDiameter, 12.0);
    
    //[self.activity.name drawInRect:nameRect withFont:[UIFont systemFontOfSize:12.0] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}


#pragma mark - Control
- (void)show
{
    if(self.isVisible)
        return;
    
    self.isVisible = YES;
    [Utils animateValueFrom:0.0 to:1.0 duration:0.6 curve:AnimationCurveElasticOut block:^(double value) {
        self.distanceFromCenter = (([Utils viewSize].width - CIRCLE_DIAMETER)/2.0)*value;
        self.circleDiameter = CIRCLE_DIAMETER*value;
        self.alpha = value;
        self.circleCenter = [self getCircleCenterFromAngle:_angle distance:self.distanceFromCenter];
    }];
}


- (void)hide
{
    if(!self.isVisible)
        return;
    
    [Utils animateValueFrom:1.0 to:0.0 duration:0.8 curve:AnimationCurveElasticIn block:^(double value) {
        self.distanceFromCenter = (([Utils viewSize].width - CIRCLE_DIAMETER)/2.0)*value;
        self.circleDiameter = CIRCLE_DIAMETER*value;
        self.alpha = value;
        self.circleCenter = [self getCircleCenterFromAngle:_angle distance:self.distanceFromCenter];
        if(value <= 0.0)
            self.isVisible = NO;
    }];
}


#pragma mark - Input
- (BOOL)isTouching:(CGPoint)touchLocation_
{
    CGFloat distance = [Utils distanceBetweenPointA:touchLocation_ pointB:self.circleCenter];
    if(distance <= CIRCLE_DIAMETER/2.0)
        return YES;
    
    return NO;
}


#pragma mark - Meta
- (Activity *)associatedActivity
{
    return self.activity;
}


- (CGPoint)getLocation
{
    return self.circleCenter;
}


- (CGFloat)getActiveDiameter
{
    return CIRCLE_DIAMETER;
}


- (BOOL)isEqual:(id)object_
{
    if([object_ class] != [ActivityElement class])
        return NO;
    
    ActivityElement *activityElement = object_;
    
    if([activityElement.associatedActivity.name isEqualToString:self.activity.name])
        return YES;
    
    return NO;
}


#pragma mark - Utils
- (CGPoint)getCircleCenterFromAngle:(CGFloat)angle_ distance:(CGFloat)distance_
{
    CGFloat xPos = [Utils viewSize].width/2.0 + sin(RAD(angle_))*distance_;
    CGFloat yPos = [Utils viewSize].height/2.0 - cos(RAD(angle_))*distance_;
    
    return CGPointMake(xPos, yPos);
}


- (NSComparisonResult)compareByIndex:(ActivityElement *)otherElement_
{
    return [self.activity.index compare:[otherElement_ associatedActivity].index];
}


- (NSComparisonResult)compareByAngle:(ActivityElement *)otherElement_
{
    if(self.angle < otherElement_.angle)
        return NSOrderedAscending;
    
    if(self.angle > otherElement_.angle)
        return NSOrderedDescending;
    
    return NSOrderedSame;
}

@end
