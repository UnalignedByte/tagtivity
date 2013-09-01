//
//  AddNewActivityElement.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 12.07.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddNewActivityElement : NSObject

//Initialization
- (id)init;

//Drawing
- (void)drawInContext:(CGContextRef)ctx_;

//Input
- (BOOL)isTouching:(CGPoint)touchLocation_;
- (BOOL)touchedAtLocation:(CGPoint)touchLocation_;
- (void)cancel;

@end
