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

//Initialization
- (id)initWithActivity:(Activity *)activity_ angle:(CGFloat)angle_;

//Drawing
- (void)drawInContext:(CGContextRef)ctx_;

//Input
- (BOOL)isTouching:(CGPoint)touchLocation_;

//Meta
- (Activity *)associatedActivity;

@end
