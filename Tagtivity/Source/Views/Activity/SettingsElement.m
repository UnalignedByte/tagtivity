//
//  SettingsElement.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 12.07.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "SettingsElement.h"

#import "Utils.h"


@interface SettingsElement ()

@property (nonatomic, assign) CGPoint circleCenter;
@property (nonatomic, assign) CGFloat circleDiameter;

@end

@implementation SettingsElement

#pragma mark - Initialization
- (id)init
{
    if((self = [super init]) == nil)
        return nil;
    
    self.circleCenter = CGPointMake([Utils viewSize].width/2.0, [Utils viewSize].height/2.0);
    self.circleDiameter = 80.0;
    
    return self;
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    CGRect circleRect = CGRectMake(self.circleCenter.x - self.circleDiameter/2.0,
                                   self.circleCenter.y - self.circleDiameter/2.0,
                                   self.circleDiameter,
                                   self.circleDiameter);
    CGContextSetStrokeColorWithColor(ctx_, [UIColor yellowColor].CGColor);
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

@end
