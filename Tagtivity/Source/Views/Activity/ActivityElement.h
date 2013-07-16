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

@property (nonatomic, assign) CGFloat newAngle;
@property (nonatomic, assign) CGFloat angle;

//Initialization
- (id)initWithActivity:(Activity *)activity_ angle:(CGFloat)angle_;

//Drawing
- (void)drawInContext:(CGContextRef)ctx_;

//Input
- (BOOL)isTouching:(CGPoint)touchLocation_;

//Meta
- (Activity *)associatedActivity;
- (BOOL)isEqual:(id)object_;
- (NSComparisonResult)compareByIndex:(ActivityElement *)otherElement_;
- (NSComparisonResult)compareByAngle:(ActivityElement *)otherElement_;

@end
