//
//  ActivityElement.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 24.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Activity;


@interface ActivityElement : NSObject

@property (nonatomic, readonly) Activity *activity;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat newAngle;
@property (nonatomic, readonly) CGPoint location;
@property (nonatomic, readonly) CGFloat diameter;

//Initialization
- (id)initWithActivity:(Activity *)activity_ angle:(CGFloat)angle_;

//Drawing
- (void)drawInContext:(CGContextRef)ctx_;

//Control
- (void)show;
- (void)showImmediately;
- (void)hide;

//Information
- (BOOL)isEqual:(id)object_;
- (NSComparisonResult)compareByIndex:(ActivityElement *)otherElement_;
- (NSComparisonResult)compareByAngle:(ActivityElement *)otherElement_;
- (BOOL)isTouching:(CGPoint)touchLocation_;

@end
