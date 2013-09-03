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


@interface AddOrDeleteActivityElement ()

@property (nonatomic, assign) CGPoint circleCenter;
@property (nonatomic, assign) CGFloat circleDiameter;

@end


@implementation AddOrDeleteActivityElement

#pragma mark - Initialization
- (id)init
{
    if((self = [super init]) == nil)
        return nil;

    self.circleDiameter = 80.0;
    CGSize screenSize = [Utils viewSize];
    self.circleCenter = CGPointMake(screenSize.width - self.circleDiameter/2.0,
                                    screenSize.height - self.circleDiameter/2.0);

    return self;
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    CGRect circleRect = CGRectMake(self.circleCenter.x - self.circleDiameter/2.0,
                                   self.circleCenter.y - self.circleDiameter/2.0,
                                   self.circleDiameter,
                                   self.circleDiameter);
    
    CGContextSetStrokeColorWithColor(ctx_, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(ctx_, 2.0);
    CGContextStrokeEllipseInRect(ctx_, circleRect);
}


#pragma mark - Input
- (BOOL)isTouching:(CGPoint)touchLocation_
{
    CGFloat distance = [Utils distanceBetweenPointA:touchLocation_ pointB:self.circleCenter];
    if(distance <= self.circleDiameter/2.0)
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
    if(distance <= self.circleDiameter/2.0)
        return YES;
    
    return NO;
}

@end
