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

@end


@implementation ActivityElement

#pragma mark - Initialization
- (id)initWithActivity:(Activity *)activity_ angle:(CGFloat)angle_;
{
    if((self = [super init]) == nil)
        return nil;
    
    self.activity = activity_;
    self.angle = angle_;
    self.circleCenter = [self getCircleCenterFromAngle:self.angle diameter:CIRCLE_DIAMETER];
    
    return self;
}


#pragma mark - Properties
- (void)setAngle:(CGFloat)angle_
{
    _angle = angle_;
    self.circleCenter = [self getCircleCenterFromAngle:angle_ diameter:CIRCLE_DIAMETER];
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    CGContextSetFillColorWithColor(ctx_, [(UIColor *)self.activity.color CGColor]);
    
    //Draw circle
    CGRect circleRect = CGRectMake(self.circleCenter.x - CIRCLE_DIAMETER/2.0, self.circleCenter.y - CIRCLE_DIAMETER/2.0,
                                   CIRCLE_DIAMETER, CIRCLE_DIAMETER);
    CGContextFillEllipseInRect(ctx_, circleRect);

    //Draw Name
    CGRect nameRect = CGRectMake(self.circleCenter.x - CIRCLE_DIAMETER/2.0,
                                 self.circleCenter.y,
                                 CIRCLE_DIAMETER, 12.0);
    
    [self.activity.name drawInRect:nameRect withFont:[UIFont systemFontOfSize:12.0] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
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
- (CGPoint)getCircleCenterFromAngle:(CGFloat)angle_ diameter:(CGFloat)diameter_
{
    CGFloat distance = [Utils viewSize].width/2.0 - diameter_/2.0;
    
    CGFloat xPos = [Utils viewSize].width/2.0 + sin(RAD(angle_))*distance;
    CGFloat yPos = [Utils viewSize].height/2.0 - cos(RAD(angle_))*distance;
    
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
