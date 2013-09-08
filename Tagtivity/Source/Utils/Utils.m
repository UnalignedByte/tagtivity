//
//  Utils.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 28.04.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "Utils.h"


@implementation Utils

+ (void)handleError:(NSError *)error_
{
    if(!error_)
        return;
    
    NSLog(@"%d: %@", error_.code, error_.description);
    abort();
}


+ (void)createDirectoryIfNecessary:(NSURL *)url_
{
    NSString *dirPath;
    
    NSString *pathExtension = [url_ pathExtension];
    if(pathExtension != nil && pathExtension.length > 0)
        dirPath = [url_ URLByDeletingLastPathComponent].path;
    else
        dirPath = url_.path;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                  withIntermediateDirectories:YES
                                                   attributes:NULL
                                                        error:NULL];
    }
}


+ (CGFloat)distanceBetweenPointA:(CGPoint)pointA_ pointB:(CGPoint)pointB_
{
    return hypot(pointB_.x - pointA_.x, pointB_.y - pointA_.y);
}


+ (CGSize)viewSize
{
    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height;
    
    if(![UIApplication sharedApplication].isStatusBarHidden)
        viewHeight -= [UIApplication sharedApplication].statusBarFrame.size.height;

    return CGSizeMake(viewWidth, viewHeight);
}


+ (CGPoint)viewCenter
{
    CGSize viewSize = [Utils viewSize];
    return CGPointMake(viewSize.width/2.0, viewSize.height/2.0);
}


+ (CGFloat)angleBetweenPointA:(CGPoint)pointA_ pointB:(CGPoint)pointB_
{
    CGFloat hypotenuseDistance = [Utils distanceBetweenPointA:pointA_ pointB:pointB_];
    CGFloat verticalDistance = abs(pointB_.y - pointA_.y);
    CGFloat sinus = verticalDistance/hypotenuseDistance;
    
    CGFloat angle = DEG(asin(sinus));
    
    BOOL isUpperHalf = pointB_.y < pointA_.y;
    BOOL isRightHalf = pointB_.x > pointA_.x;
    
    if(isUpperHalf && isRightHalf)
        angle = 90.0 - angle;
    else if(!isUpperHalf && isRightHalf)
        angle = 90.0 + angle;
    else if(!isUpperHalf && !isRightHalf)
        angle = 270.0 - angle;
    else
        angle = 270.0 + angle;
    
    //We want angle to be in range of -180.0 to 180.0
    if(angle > 180.0)
        angle = -360.0 + angle;
    
    return angle;
}


+ (void)executeBlocksInArray:(NSArray *)array_
{
    for(void (^block)() in array_) {
        block();
    }
}


static NSMutableArray *animationsArray;

+ (void)animateValueFrom:(CGFloat)startValue_ to:(CGFloat)endValue_ duration:(CGFloat)duration_ block:(void (^)(double))block_
{
    static CADisplayLink *animationDisplayLink;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        animationsArray = [NSMutableArray array];
        
        animationDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTimerFired:)];
        [animationDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    });

    NSMutableArray *animationArray = [NSMutableArray arrayWithObjects:@(startValue_), @(endValue_), @(duration_), @(0.0), [block_ copy], nil];
    [animationsArray addObject:animationArray];
}


+ (void)animationTimerFired:(CADisplayLink *)animationDisplayLink_
{
    NSMutableArray *animationsForRemoval = [NSMutableArray array];
    
    static CGFloat lastTime = 0.0;
    if(lastTime == 0.0) {
        lastTime = animationDisplayLink_.timestamp;
        return;
    }
    
    CGFloat timeInterval = animationDisplayLink_.timestamp - lastTime;
    lastTime = animationDisplayLink_.timestamp;
    
    for(NSMutableArray *animationArray in animationsArray) {
        double startValue = [animationArray[0] doubleValue];
        double endValue = [animationArray[1] doubleValue];
        double duration = [animationArray[2] doubleValue];
        double timeElapsed = [animationArray[3] doubleValue];
        void (^block)(double) = animationArray[4];
        
        timeElapsed += timeInterval;
        [animationArray replaceObjectAtIndex:3 withObject:@(timeElapsed)];
        
        double currentValue = 0.0;
        double deltaValue = endValue-startValue;
        
        //Linear
        //currentValue = startValue + deltaValue*timeElapsed/duration;
        
        //Quadratic
        double time = timeElapsed / (duration / 2.0);
        if(time < 1.0) {
            currentValue = deltaValue/2.0*time*time + startValue;
        } else {
            time--;
            currentValue = -deltaValue/2.0 * (time*(time-2.0) - 1.0) + startValue;
        }
        
        
        if(timeElapsed >= duration)
            currentValue = endValue;
        
        if(currentValue == endValue) {
            [animationsForRemoval addObject:animationArray];
        }
        
        block(currentValue);
    }
    
    for(NSMutableArray *animationForRemoval in animationsForRemoval) {
        [animationsArray removeObject:animationForRemoval];
    }
}

@end
