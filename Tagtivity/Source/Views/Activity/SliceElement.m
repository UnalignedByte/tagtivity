//
//  SliceElement.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 29.09.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "SliceElement.h"

#import "ActivityElement.h"

#import "Utils.h"


@interface SliceElement ()

@property (nonatomic, assign) BOOL isSlicing;

@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGPoint currentLocation;

@end


@implementation SliceElement

#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    if(self.isSlicing) {
    }
}


#pragma mark - Control
- (void)startSlicingWithLocation:(CGPoint)touchLocation_
{
    self.startLocation = touchLocation_;
    self.currentLocation = touchLocation_;
    
    self.isSlicing = YES;
}


- (void)setCurrentTouchLocation:(CGPoint)touchLocation_
{
    self.currentLocation = touchLocation_;
}


- (void)cancelSlicingWithLocation:(CGPoint)touchLocation_
{
    self.currentLocation = touchLocation_;
    
    self.isSlicing = NO;
}


- (void)endSlicingWithLocation:(CGPoint)touchLocation_
{
    self.currentLocation = touchLocation_;
    self.isSlicing = NO;
}


- (BOOL)hasSlicedThroughActivityElement:(ActivityElement *)activityElement_
{
    CGFloat sliceLength = [Utils distanceBetweenPointA:self.startLocation pointB:self.currentLocation];
    CGFloat elementDiameter = [activityElement_ getActiveDiameter];
    CGPoint elementLocation = [activityElement_ getLocation];
    
    //Slice should at least the length of element's diameter
    if(sliceLength < elementDiameter)
        return NO;
    
    //Slice endpoints should be outside the element
    if([Utils distanceBetweenPointA:self.startLocation pointB:elementLocation] < elementDiameter*0.5)
        return NO;
    
    if([Utils distanceBetweenPointA:self.currentLocation pointB:elementLocation] < elementDiameter*0.5)
        return NO;
    
    CGPoint closestPoint = [Utils closestPointBetweenLinePointA:self.startLocation linePointB:self.currentLocation andPoint:elementLocation];

    //Slice should go through the element
    if([Utils distanceBetweenPointA:closestPoint pointB:elementLocation] > elementDiameter*0.5)
        return NO;
    
    //Both points should be on the oposite sides of elemenet, outside of it
    if([Utils distanceBetweenPointA:self.startLocation pointB:closestPoint] > sliceLength)
        return NO;
    
    if([Utils distanceBetweenPointA:self.currentLocation pointB:closestPoint] > sliceLength)
        return NO;
    
    return YES;
}

@end
