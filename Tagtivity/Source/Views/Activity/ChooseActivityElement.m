//
//  ChooseActivityElement.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 12.07.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ChooseActivityElement.h"

#import "Utils.h"


@interface ChooseActivityElement ()

@property (nonatomic, assign) CGFloat circleDiameter;

@end


@implementation ChooseActivityElement

#pragma mark - Initialization
- (id)init
{
    if((self = [super init]) == nil)
        return nil;
    
    _circleCenter = CGPointMake([Utils viewSize].width/2.0, [Utils viewSize].height/2.0);
    self.circleDiameter = 80.0;
    
    return self;
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    CGRect circleRect = CGRectMake(_circleCenter.x - self.circleDiameter/2.0,
                                   _circleCenter.y - self.circleDiameter/2.0,
                                   self.circleDiameter, self.circleDiameter);
    
    CGContextSetStrokeColorWithColor(ctx_, [UIColor redColor].CGColor);
    CGContextSetLineWidth(ctx_, 4.0);
    CGContextStrokeEllipseInRect(ctx_, circleRect);
}


#pragma mark - Input
- (BOOL)isTouching:(CGPoint)touchLocation_
{
    CGFloat distance = [Utils distanceBetweenPointA:touchLocation_ pointB:_circleCenter];
    if(distance <= self.circleDiameter/2.0)
        return YES;
    
    return NO;
}

@end
