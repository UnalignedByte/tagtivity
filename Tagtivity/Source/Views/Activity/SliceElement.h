//
//  SliceElement.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 29.09.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ActivityElement;


@interface SliceElement : NSObject

//Drawing
- (void)drawInContext:(CGContextRef)ctx_;

//Control
- (void)startSlicingWithLocation:(CGPoint)touchLocation_;
- (void)setCurrentTouchLocation:(CGPoint)touchLocation_;
- (void)cancelSlicingWithLocation:(CGPoint)touchLocation_;
- (void)endSlicingWithLocation:(CGPoint)touchLocation_;

- (BOOL)hasSlicedThroughActivityElement:(ActivityElement *)activityElement_;

@end
