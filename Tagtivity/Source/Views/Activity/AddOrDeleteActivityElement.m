//
//  AddOrDeleteActivityElement.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 12.07.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "AddOrDeleteActivityElement.h"

#import "Utils.h"


#define ADD_DISTANCE 100.0
#define BIG_CIRCLE_DIAMETER 70.0
#define SMALL_CIRCLE_DIAMETER 40.0


@interface AddOrDeleteActivityElement ()

@property (nonatomic, assign) CGPoint circleCenter;

@property (nonatomic, assign) CGFloat smallCircleDiameter;
@property (nonatomic, assign) CGPoint currentTouchLocation;
@property (nonatomic, assign) BOOL isAdding;
@property (nonatomic, assign) BOOL isDeleting;

@end


@implementation AddOrDeleteActivityElement

#pragma mark - Initialization
- (id)init
{
    if((self = [super init]) == nil)
        return nil;

    CGSize screenSize = [Utils viewSize];
    self.circleCenter = CGPointMake(screenSize.width - BIG_CIRCLE_DIAMETER/2.0,
                                    screenSize.height - BIG_CIRCLE_DIAMETER/2.0);

    return self;
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    if(self.isAdding) {
        //Calculate multipliers
        CGFloat distance = [Utils distanceBetweenPointA:self.circleCenter pointB:self.currentTouchLocation];
        
        CGFloat smallCircleMultiplier = 1.0 - distance/400.0;
        if(smallCircleMultiplier < 0.4)
            smallCircleMultiplier = 0.4;
        else if(smallCircleMultiplier > 1.0)
            smallCircleMultiplier = 1.0;
        
        CGFloat bigCircleMultiplier = 1.0 - distance/1000.0;
        if(bigCircleMultiplier < 0.8)
            bigCircleMultiplier = 0.8;
        else if(bigCircleMultiplier > 1.0)
            bigCircleMultiplier = 1.0;
        
        CGFloat angleMultiplier = distance/50.0;
        if(angleMultiplier > 4.0)
            angleMultiplier = 4.0;
        else if(angleMultiplier < 1.0)
            angleMultiplier = 1.0;
        
        CGFloat curveMultiplier = 1.0 + (distance/400);
        if(curveMultiplier > 4.0)
            curveMultiplier = 4.0;
        else if(curveMultiplier < 1.0)
            curveMultiplier = 1.0;
        
        //Calculate sizes
        CGFloat bigCircleRadius = (BIG_CIRCLE_DIAMETER/2.0)*bigCircleMultiplier;
        CGFloat smallCircleRadius = (SMALL_CIRCLE_DIAMETER/2.0)*smallCircleMultiplier;
        CGFloat stretchPointAngle = 15.0*angleMultiplier;
        
        CGRect bigCircleRect = CGRectMake(self.circleCenter.x - bigCircleRadius,
                                          self.circleCenter.y - bigCircleRadius,
                                          bigCircleRadius*2.0, bigCircleRadius*2.0);
        CGRect smallCircleRect = CGRectMake(self.currentTouchLocation.x - smallCircleRadius,
                                            self.currentTouchLocation.y - smallCircleRadius,
                                            smallCircleRadius*2.0, smallCircleRadius*2.0);
        
        CGFloat angle = [Utils angleBetweenPointA:self.circleCenter pointB:self.currentTouchLocation];
        
        CGFloat rightArcBigX = self.circleCenter.x + sin(RAD(angle+stretchPointAngle))*bigCircleRadius;
        CGFloat rightArcBigY = self.circleCenter.y - cos(RAD(angle+stretchPointAngle))*bigCircleRadius;
        
        CGFloat rightArcSmallX = self.currentTouchLocation.x + sin(RAD(angle+90.0))*smallCircleRadius;
        CGFloat rightArcSmallY = self.currentTouchLocation.y - cos(RAD(angle+90.0))*smallCircleRadius;
        
        CGFloat leftArcBigX = self.circleCenter.x + sin(RAD(angle-stretchPointAngle))*bigCircleRadius;
        CGFloat leftArcBigY = self.circleCenter.y - cos(RAD(angle-stretchPointAngle))*bigCircleRadius;
        
        CGFloat leftArcSmallX = self.currentTouchLocation.x + sin(RAD(angle-90.0))*smallCircleRadius;
        CGFloat leftArcSmallY = self.currentTouchLocation.y - cos(RAD(angle-90.0))*smallCircleRadius;

        //Draw circles
        CGContextSetStrokeColorWithColor(ctx_, [UIColor greenColor].CGColor);
        CGContextSetFillColorWithColor(ctx_, [UIColor redColor].CGColor);
        CGContextSetLineWidth(ctx_, 2.0);

        CGContextFillEllipseInRect(ctx_, bigCircleRect);
        CGContextFillEllipseInRect(ctx_, smallCircleRect);

        //Add right arc
        CGContextBeginPath(ctx_);
        CGContextMoveToPoint(ctx_, rightArcBigX, rightArcBigY);
        
        CGContextAddCurveToPoint(ctx_,
                                 self.circleCenter.x - (self.circleCenter.x-self.currentTouchLocation.x)/(2.0*curveMultiplier),
                                 self.circleCenter.y - (self.circleCenter.y-self.currentTouchLocation.y)/(2.0*curveMultiplier),
                                 self.currentTouchLocation.x + (self.circleCenter.x-self.currentTouchLocation.x)/(2.0*curveMultiplier),
                                 self.currentTouchLocation.y + (self.circleCenter.y-self.currentTouchLocation.y)/(2.0*curveMultiplier),
                                 rightArcSmallX, rightArcSmallY);

        //Add line joining the arcs
        CGContextAddLineToPoint(ctx_, leftArcSmallX, leftArcSmallY);
        
        //Add left arc
        CGContextAddCurveToPoint(ctx_,
                                 self.circleCenter.x - (self.circleCenter.x-self.currentTouchLocation.x)/2.0,
                                 self.circleCenter.y - (self.circleCenter.y-self.currentTouchLocation.y)/2.0,
                                 self.circleCenter.x - (self.circleCenter.x-self.currentTouchLocation.x)/(2.0*curveMultiplier),
                                 self.circleCenter.y - (self.circleCenter.y-self.currentTouchLocation.y)/(2.0*curveMultiplier),
                                 leftArcBigX, leftArcBigY);
        
        CGContextFillPath(ctx_);
    } else {
        CGRect circleRect = CGRectMake(self.circleCenter.x - BIG_CIRCLE_DIAMETER/2.0,
                                       self.circleCenter.y - BIG_CIRCLE_DIAMETER/2.0,
                                       BIG_CIRCLE_DIAMETER,
                                       BIG_CIRCLE_DIAMETER);
        
        CGContextSetFillColorWithColor(ctx_, [UIColor redColor].CGColor);
        CGContextFillEllipseInRect(ctx_, circleRect);
    }
}


#pragma mark - Control
- (void)startAddingWithCurrentLoation:(CGPoint)touchLocation_
{
    self.currentTouchLocation = touchLocation_;
    
    self.isAdding = YES;
}


- (void)stopAddingWithCurrentLocation:(CGPoint)touchLocation_ isCanceled:(BOOL)isCanceled_
{
    self.currentTouchLocation = touchLocation_;

    if(isCanceled_) {
        [Utils animateValueFrom:self.currentTouchLocation.x to:self.circleCenter.x duration:0.2 block:^(double value) {
            self.currentTouchLocation = CGPointMake(value, self.currentTouchLocation.y);
        }];
        
        [Utils animateValueFrom:self.currentTouchLocation.y to:self.circleCenter.y duration:0.2 block:^(double value) {
            self.currentTouchLocation = CGPointMake(self.currentTouchLocation.x, value);
            if(value == self.circleCenter.y)
                self.isAdding = NO;
        }];
    } else {
        self.isAdding = NO;
    }
}


- (void)setCurrentTouchingLocation:(CGPoint)touchLocation_
{
    self.currentTouchLocation = touchLocation_;
}


#pragma mark - Input
- (BOOL)isTouching:(CGPoint)touchLocation_
{
    CGFloat distance = [Utils distanceBetweenPointA:touchLocation_ pointB:self.circleCenter];
    if(distance <= BIG_CIRCLE_DIAMETER/2.0)
        return YES;
    
    return NO;
}


- (BOOL)isTouchingAddLocation:(CGPoint)touchLocation_
{
    CGSize viewSize = [Utils viewSize];
    CGPoint viewCenter = CGPointMake(viewSize.width/2.0, viewSize.height/2.0);
    
    return [Utils distanceBetweenPointA:touchLocation_ pointB:viewCenter] < ADD_DISTANCE;
}


- (BOOL)isTouchingDeleteLocation:(CGPoint)touchLocation_
{
    CGFloat distance = [Utils distanceBetweenPointA:touchLocation_ pointB:self.circleCenter];
    if(distance <= BIG_CIRCLE_DIAMETER/2.0)
        return YES;
    
    return NO;
}

@end
