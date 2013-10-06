//
//  Utils.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 28.04.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <Foundation/Foundation.h>


#define RAD(deg) (M_PI*(deg)/180.0)
#define DEG(rad) ((rad)*180.0/M_PI)


@interface Utils : NSObject

+ (void)handleError:(NSError *)error_;
+ (void)createDirectoryIfNecessary:(NSURL *)url_;
+ (CGFloat)distanceBetweenPointA:(CGPoint)pointA_ pointB:(CGPoint)pointB_;
+ (CGPoint)closestPointBetweenLinePointA:(CGPoint)linePointA_ linePointB:(CGPoint)linePointB_ andPoint:(CGPoint)point_;
+ (CGSize)viewSize;
+ (CGPoint)viewCenter;
+ (CGFloat)angleBetweenPointA:(CGPoint)pointA_ pointB:(CGPoint)pointB_;
+ (void)executeBlocksInArray:(NSArray *)array_;
+ (void)animateValueFrom:(CGFloat)startValue_ to:(CGFloat)endValue_ duration:(CGFloat)duration_ block:(void (^)(double value))block_;

@end
