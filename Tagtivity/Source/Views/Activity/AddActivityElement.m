//
//  AddActivityElement.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 12.07.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "AddActivityElement.h"

#import "Utils.h"


#define ADD_DISTANCE 100.0
#define BIG_CIRCLE_DIAMETER 70.0
#define SMALL_CIRCLE_DIAMETER 40.0

#define FINISH_ADDING_ANIMATION_DURATION 0.3

typedef enum {
    ADD_DELETE_STATE_DEFAULT,
    ADD_DELETE_STATE_ADDING,
    ADD_DELETE_STATE_FINISH_ADDING,
    ADD_DELETE_STATE_DELETING
} AddDeleteState;


@interface AddActivityElement ()

@property (nonatomic, assign) AddDeleteState state;

@property (nonatomic, assign) CGPoint bigCircleCenter;
@property (nonatomic, assign) CGFloat bigCircleDiameter;
@property (nonatomic, assign) CGPoint smallCircleCenter;
@property (nonatomic, assign) CGFloat smallCircleDiamter;

@property (nonatomic, assign) CGPoint currentTouchLocation;

@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) CGFloat drawRed;
@property (nonatomic, assign) CGFloat drawGreen;
@property (nonatomic, assign) CGFloat drawBlue;
@property (nonatomic, assign) CGFloat drawAlpha;
@property (nonatomic, assign) CGFloat drawDiameter;
@property (nonatomic, assign) CGPoint drawBigCircleLocation;

@end


@implementation AddActivityElement

#pragma mark - Initialization
- (id)init
{
    if((self = [super init]) == nil)
        return nil;

    self.state = ADD_DELETE_STATE_DEFAULT;

    return self;
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    if(!self.isVisible)
        return;

    switch(self.state) {
        case ADD_DELETE_STATE_DEFAULT:
        {
            CGSize screenSize = [Utils viewSize];
            self.bigCircleCenter = CGPointMake(screenSize.width - BIG_CIRCLE_DIAMETER/2.0,
                                               screenSize.height - BIG_CIRCLE_DIAMETER/2.0);

            CGRect circleRect = CGRectMake(self.bigCircleCenter.x - self.drawDiameter/2.0,
                                           self.bigCircleCenter.y - self.drawDiameter/2.0,
                                           self.drawDiameter, self.drawDiameter);

            UIColor *color = [UIColor colorWithRed:self.drawRed green:self.drawGreen blue:self.drawBlue alpha:self.drawAlpha];
            CGContextSetFillColorWithColor(ctx_, color.CGColor);
            CGContextFillEllipseInRect(ctx_, circleRect);
        }
            break;
        case ADD_DELETE_STATE_ADDING:
        {
            //Calculate multipliers
            CGFloat distance = [Utils distanceBetweenPointA:self.bigCircleCenter pointB:self.smallCircleCenter];
            
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

            //Calculate sizes
            self.bigCircleDiameter = BIG_CIRCLE_DIAMETER*bigCircleMultiplier;
            self.smallCircleDiamter = SMALL_CIRCLE_DIAMETER*smallCircleMultiplier;
            
            //Set locations
            CGSize screenSize = [Utils viewSize];
            self.bigCircleCenter = CGPointMake(screenSize.width - BIG_CIRCLE_DIAMETER/2.0,
                                               screenSize.height - BIG_CIRCLE_DIAMETER/2.0);
            
            [self drawAddingStretchInContext:ctx_];
        }
            break;
        case ADD_DELETE_STATE_FINISH_ADDING:
        {
            [self drawAddingStretchInContext:ctx_];
        }
            break;
        case ADD_DELETE_STATE_DELETING:
        {
        }
            break;
    }
}


- (void)drawAddingStretchInContext:(CGContextRef)ctx_
{
    //Calculate multipliers
    CGFloat distance = [Utils distanceBetweenPointA:self.bigCircleCenter pointB:self.smallCircleCenter];
    
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
    
    //Calculate values
    CGFloat stretchPointAngle = 15.0*angleMultiplier;
    
    CGRect bigCircleRect = CGRectMake(self.bigCircleCenter.x - self.bigCircleDiameter/2.0,
                                      self.bigCircleCenter.y - self.bigCircleDiameter/2.0,
                                      self.bigCircleDiameter, self.bigCircleDiameter);
    CGRect smallCircleRect = CGRectMake(self.smallCircleCenter.x - self.smallCircleDiamter/2.0,
                                        self.smallCircleCenter.y - self.smallCircleDiamter/2.0,
                                        self.smallCircleDiamter, self.smallCircleDiamter);
    
    CGFloat angle = [Utils angleBetweenPointA:self.bigCircleCenter pointB:self.smallCircleCenter];
    
    CGFloat rightArcBigX = self.bigCircleCenter.x + sin(RAD(angle+stretchPointAngle))*self.bigCircleDiameter/2.0;
    CGFloat rightArcBigY = self.bigCircleCenter.y - cos(RAD(angle+stretchPointAngle))*self.bigCircleDiameter/2.0;
    
    CGFloat leftArcBigX = self.bigCircleCenter.x + sin(RAD(angle-stretchPointAngle))*self.bigCircleDiameter/2.0;
    CGFloat leftArcBigY = self.bigCircleCenter.y - cos(RAD(angle-stretchPointAngle))*self.bigCircleDiameter/2.0;
    
    CGFloat rightArcSmallX = self.smallCircleCenter.x + sin(RAD(angle+90.0))*self.smallCircleDiamter/2.0;
    CGFloat rightArcSmallY = self.smallCircleCenter.y - cos(RAD(angle+90.0))*self.smallCircleDiamter/2.0;
    
    CGFloat leftArcSmallX = self.smallCircleCenter.x + sin(RAD(angle-90.0))*self.smallCircleDiamter/2.0;
    CGFloat leftArcSmallY = self.smallCircleCenter.y - cos(RAD(angle-90.0))*self.smallCircleDiamter/2.0;
    
    //Draw circles
    //CGContextSetFillColorWithColor(ctx_, [UIColor greenColor].CGColor);
    UIColor *color = [UIColor colorWithRed:self.drawRed green:self.drawGreen blue:self.drawBlue alpha:self.drawAlpha];
    CGContextSetFillColorWithColor(ctx_, color.CGColor);
    
    CGContextFillEllipseInRect(ctx_, bigCircleRect);
    CGContextFillEllipseInRect(ctx_, smallCircleRect);
    
    //Add right arc
    CGContextBeginPath(ctx_);
    CGContextMoveToPoint(ctx_, rightArcBigX, rightArcBigY);
    
    CGContextAddCurveToPoint(ctx_,
                             self.bigCircleCenter.x - (self.bigCircleCenter.x-self.smallCircleCenter.x)/(2.0*curveMultiplier),
                             self.bigCircleCenter.y - (self.bigCircleCenter.y-self.smallCircleCenter.y)/(2.0*curveMultiplier),
                             self.smallCircleCenter.x + (self.bigCircleCenter.x-self.smallCircleCenter.x)/(2.0*curveMultiplier),
                             self.smallCircleCenter.y + (self.bigCircleCenter.y-self.smallCircleCenter.y)/(2.0*curveMultiplier),
                             rightArcSmallX, rightArcSmallY);
    
    //Add line joining the arcs
    CGContextAddLineToPoint(ctx_, leftArcSmallX, leftArcSmallY);
    
    //Add left arc
    CGContextAddCurveToPoint(ctx_,
                             self.bigCircleCenter.x - (self.bigCircleCenter.x-self.smallCircleCenter.x)/2.0,
                             self.bigCircleCenter.y - (self.bigCircleCenter.y-self.smallCircleCenter.y)/2.0,
                             self.bigCircleCenter.x - (self.bigCircleCenter.x-self.smallCircleCenter.x)/(2.0*curveMultiplier),
                             self.bigCircleCenter.y - (self.bigCircleCenter.y-self.smallCircleCenter.y)/(2.0*curveMultiplier),
                             leftArcBigX, leftArcBigY);
    
    CGContextFillPath(ctx_);
}


#pragma mark - Control
- (void)show
{
    self.drawRed = 0.0;
    self.drawGreen = 0.0;
    self.drawBlue = 0.0;
    self.drawAlpha = 0.0;
    
    self.isVisible = YES;
    [Utils animateValueFrom:0.0 to:1.0 duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawAlpha = value*0.1;
        self.drawDiameter = BIG_CIRCLE_DIAMETER*value;
    }];
}


- (void)hide
{
    self.drawRed = 0.0;
    self.drawGreen = 0.0;
    self.drawBlue = 0.0;
    self.drawAlpha = 0.1;
    
    [Utils animateValueFrom:1.0 to:0.0 duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawAlpha = value*0.1;
        self.drawDiameter = BIG_CIRCLE_DIAMETER*value;
        if(value == 0.0)
            self.isVisible = NO;
    }];
}


- (void)startAddingWithCurrentLoation:(CGPoint)touchLocation_ color:(UIColor *)color_
{
    self.currentTouchLocation = touchLocation_;
    self.smallCircleCenter = touchLocation_;
    
    const CGFloat *colorComponents = CGColorGetComponents(color_.CGColor);

    [Utils animateValueFrom:self.drawRed to:colorComponents[0] duration:0.2 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawRed = value;
    }];
    
    [Utils animateValueFrom:self.drawGreen to:colorComponents[1] duration:0.2 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawGreen = value;
    }];
    
    [Utils animateValueFrom:self.drawBlue to:colorComponents[2] duration:0.2 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawBlue = value;
    }];

    [Utils animateValueFrom:self.drawAlpha to:colorComponents[3] duration:0.2 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawAlpha = value;
    }];
    
    self.state = ADD_DELETE_STATE_ADDING;
}


- (void)cancelAddingWithCurrentLocation:(CGPoint)touchLocation_
{
    [Utils animateValueFrom:touchLocation_.x to:self.bigCircleCenter.x duration:FINISH_ADDING_ANIMATION_DURATION curve:AnimationCurveQuadraticIn block:^(double value) {
        self.smallCircleCenter = CGPointMake(value, self.smallCircleCenter.y);
    }];
    
    [Utils animateValueFrom:touchLocation_.y to:self.bigCircleCenter.y duration:FINISH_ADDING_ANIMATION_DURATION curve:AnimationCurveQuadraticIn block:^(double value) {
        self.smallCircleCenter = CGPointMake(self.smallCircleCenter.x, value);
        if(value == self.bigCircleCenter.y)
            self.state = ADD_DELETE_STATE_DEFAULT;
    }];
    
    [Utils animateValueFrom:self.drawRed to:0.0 duration:0.2 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawRed = value;
    }];
    
    [Utils animateValueFrom:self.drawGreen to:0.0 duration:0.2 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawGreen = value;
    }];
    
    [Utils animateValueFrom:self.drawBlue to:0.0 duration:0.2 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawBlue = value;
    }];
    
    [Utils animateValueFrom:self.drawAlpha to:0.1 duration:0.2 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.drawAlpha = value;
    }];
}


- (void)finishAddingWithAddLocation:(CGPoint)addLocation_ activityElementDiameter:(CGFloat)activityElementDiameter_  completed:(void (^)())completedBlock_
{
    self.state = ADD_DELETE_STATE_FINISH_ADDING;
    
    [Utils animateValueFrom:self.smallCircleCenter.x to:addLocation_.x duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.smallCircleCenter = CGPointMake(value, self.smallCircleCenter.y);
    }];
    
    [Utils animateValueFrom:self.smallCircleCenter.y to:addLocation_.y duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.smallCircleCenter = CGPointMake(self.smallCircleCenter.x, value);
    }];
    
    [Utils animateValueFrom:self.bigCircleCenter.x to:addLocation_.x duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.bigCircleCenter = CGPointMake(value, self.bigCircleCenter.y);
    }];
    
    [Utils animateValueFrom:self.bigCircleCenter.y to:addLocation_.y duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.bigCircleCenter = CGPointMake(self.bigCircleCenter.x, value);
    }];
    
    [Utils animateValueFrom:self.bigCircleDiameter to:1.0 duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
        self.bigCircleDiameter = value;
    }];

    [Utils animateValueFrom:self.smallCircleDiamter to:activityElementDiameter_ duration:0.6 curve:AnimationCurveElasticOut block:^(double value) {
        self.smallCircleDiamter = value;
        if(value == activityElementDiameter_) {
            self.state = ADD_DELETE_STATE_DEFAULT;
            self.drawRed = 0.0;
            self.drawGreen = 0.0;
            self.drawBlue = 0.0;
            self.drawAlpha = 0.0;
            [Utils animateValueFrom:0.0 to:1.0 duration:0.5 curve:AnimationCurveQuadraticInOut block:^(double value) {
                self.drawAlpha = value*0.1;
                self.drawDiameter = BIG_CIRCLE_DIAMETER*value;
            }];
            completedBlock_();
        }
    }];
}


- (void)setCurrentTouchingLocation:(CGPoint)touchLocation_
{
    self.currentTouchLocation = touchLocation_;
    
    if(self.state == ADD_DELETE_STATE_ADDING)
        self.smallCircleCenter = touchLocation_;
}


#pragma mark - Input
- (BOOL)isTouching:(CGPoint)touchLocation_
{
    CGFloat distance = [Utils distanceBetweenPointA:touchLocation_ pointB:self.bigCircleCenter];
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

@end
