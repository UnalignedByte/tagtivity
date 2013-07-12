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


#define RAD(deg) M_PI*deg/180.0
#define CIRCLE_DIAMETER 80.0


@interface ActivityElement ()

@property (nonatomic, strong) Activity *activity;
@property (nonatomic, assign) CGFloat angle;
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
    
    CGFloat distance = [Utils viewSize].width/2.0 - CIRCLE_DIAMETER/2.0;
    
    CGFloat xPos = [Utils viewSize].width/2.0 + sin(RAD(self.angle))*distance;
    CGFloat yPos = [Utils viewSize].height/2.0 - cos(RAD(self.angle))*distance;
    
    self.circleCenter = CGPointMake(xPos, yPos);
    
    return self;
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    CGRect circleRect = CGRectMake(self.circleCenter.x - CIRCLE_DIAMETER/2.0, self.circleCenter.y - CIRCLE_DIAMETER/2.0,
                                   CIRCLE_DIAMETER, CIRCLE_DIAMETER);
    CGContextSetStrokeColorWithColor(ctx_, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(ctx_, 1.0);
    CGContextStrokeEllipseInRect(ctx_, circleRect);
    
    CGRect nameRect = CGRectMake(self.circleCenter.x - CIRCLE_DIAMETER/2.0, self.circleCenter.y,
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

@end
