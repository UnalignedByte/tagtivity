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


+ (CGPoint)closestPointBetweenLinePointA:(CGPoint)linePointA_ linePointB:(CGPoint)linePointB_ andPoint:(CGPoint)point_
{
    CGFloat lineLength = [Utils distanceBetweenPointA:linePointA_ pointB:linePointB_];
    
    if(lineLength == 0.0)
        return linePointA_;
    
    CGFloat u = ((point_.x - linePointA_.x) * (linePointB_.x - linePointA_.x) + (point_.y - linePointA_.y) * (linePointB_.y - linePointA_.y)) / (lineLength*lineLength);
    if(u < 0.0)
        return linePointA_;
    if(u > 1.0)
        return linePointB_;
    
    CGPoint intersectionPoint = CGPointMake(linePointA_.x + u*(linePointB_.x-linePointA_.x),
                                            linePointA_.y + u*(linePointB_.y-linePointA_.y));
    
    return intersectionPoint;
}


+ (CGSize)viewSize
{
    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height;
    
    //if(![UIApplication sharedApplication].isStatusBarHidden)
    //    viewHeight -= [UIApplication sharedApplication].statusBarFrame.size.height;

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
    if(hypotenuseDistance == 0)
        return 0.0;
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
static NSLock *animationsArrayLock;

+ (void)animateValueFrom:(CGFloat)startValue_ to:(CGFloat)endValue_ duration:(CGFloat)duration_ curve:(AnimaitonCurve)animationCurve_ block:(void (^)(double))block_
{
    static CADisplayLink *animationDisplayLink;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        animationsArray = [NSMutableArray array];
        animationsArrayLock = [[NSLock alloc] init];
        
        animationDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTimerFired:)];
        [animationDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    });

    [animationsArrayLock lock];
    
    NSMutableArray *animationArray = [NSMutableArray arrayWithObjects:@(startValue_), @(endValue_), @(duration_), @(0.0), @(animationCurve_), [block_ copy], nil];
    [animationsArray addObject:animationArray];

    [animationsArrayLock unlock];
}


+ (void)animationTimerFired:(CADisplayLink *)animationDisplayLink_
{
    if(![animationsArrayLock tryLock])
        return;
    
    NSMutableArray *animationsForRemoval = [NSMutableArray array];

    static CGFloat lastTime = 0.0;
    if(lastTime == 0.0) {
        lastTime = animationDisplayLink_.timestamp;
        [animationsArrayLock unlock];
        return;
    }
    
    CGFloat timeInterval = animationDisplayLink_.timestamp - lastTime;
    lastTime = animationDisplayLink_.timestamp;
    
    for(NSMutableArray *animationArray in animationsArray) {
        double startValue = [animationArray[0] doubleValue];
        double endValue = [animationArray[1] doubleValue];
        double duration = [animationArray[2] doubleValue];
        double timeElapsed = [animationArray[3] doubleValue];
        AnimaitonCurve animationCurve = [animationArray[4] integerValue];;
        void (^block)(double) = animationArray[5];
        
        timeElapsed += timeInterval;
        [animationArray replaceObjectAtIndex:3 withObject:@(timeElapsed)];
        
        CGFloat deltaValue = endValue-startValue;

        CGFloat multiplier;
        switch(animationCurve) {
            case AnimationCurveQuadraticIn:
                multiplier = [Utils animationTimingFunctionQuadraticIn:timeElapsed duration:duration];
                break;
            case AnimationCurveQuadraticOut:
                multiplier = [Utils animationTimingFunctionQuadraticOut:timeElapsed duration:duration];
                break;
            case AnimationCurveQuadraticInOut:
                multiplier = [Utils animationTimingFunctionQuadraticInOut:timeElapsed duration:duration];
                break;
            case AnimationCurveElasticIn:
                multiplier = [Utils animationTimingFunctionElasticIn:timeElapsed duration:duration];
                break;
            case AnimationCurveElasticOut:
                multiplier = [Utils animationTimingFunctionElasticOut:timeElapsed duration:duration];
                break;
            case AnimationCurveElasticInOut:
                multiplier = [Utils animationTimingFunctionElasticInOut:timeElapsed duration:duration];
                break;
            case AnimationCurveLinear:
            default:
                multiplier = [Utils animationTimingFunctionLinear:timeElapsed duration:duration];
                break;
        }
        
       CGFloat currentValue = startValue + deltaValue * multiplier;
        
        if(timeElapsed >= duration) {
            currentValue = endValue;
            [animationsForRemoval addObject:animationArray];
        }

        dispatch_async(dispatch_get_main_queue(), ^(){
            block(currentValue);
        });
    }
    
    for(NSMutableArray *animationForRemoval in animationsForRemoval) {
        [animationsArray removeObject:animationForRemoval];
    }
    
    [animationsArrayLock unlock];
}


#pragma mark - Animation Timing Functions
+ (CGFloat)animationTimingFunctionLinear:(CGFloat)time_ duration:(CGFloat)duration_
{
    if(time_ <= 0.0)
        return 0.0;
    
    time_ /= duration_;
    
    if(time_ >= 1.0)
        return 1.0;
    
    return time_;
}


+ (CGFloat)animationTimingFunctionElasticIn:(CGFloat)time_ duration:(CGFloat)duration_
{
    if(time_ <= 0.0)
        return 0.0;
    
    time_ /= duration_;
    
    if(time_ >= 1.0)
        return 1.0;
    
    CGFloat period = duration_ * 0.3;
    CGFloat s = period * 0.25;
    
    time_ -= 1.0;
    
    return -(pow(2.0, 10.0 * time_) * sin((time_ * duration_ - s) * (2.0 * M_PI) / period));
}


+ (CGFloat)animationTimingFunctionQuadraticIn:(CGFloat)time_ duration:(CGFloat)duration_
{
    if(time_ <= 0.0)
        return 0.0;
    
    time_ /= duration_;
    
    if(time_ >= 1.0)
        return 1.0;
    
    return time_ * time_;
}


+ (CGFloat)animationTimingFunctionQuadraticOut:(CGFloat)time_ duration:(CGFloat)duration_
{
    if(time_ <= 0.0)
        return 0.0;
    
    time_ /= duration_;
    
    if(time_ >= 1.0)
        return 1.0;
    
    return -time_ * (time_ - 2.0);
}


+ (CGFloat)animationTimingFunctionQuadraticInOut:(CGFloat)time_ duration:(CGFloat)duration_
{
    if(time_ <= 0.0)
        return 0.0;
    
    time_ /= duration_ * 0.5;
    
    if(time_ >= 2.0)
        return 1.0;
    
    if(time_ < 1.0)
        return 0.5 * time_ * time_;


    time_ -= 1.0;
    return -0.5 * (time_ * (time_ - 2.0) - 1.0);
}


+ (CGFloat)animationTimingFunctionElasticOut:(CGFloat)time_ duration:(CGFloat)duration_
{
    if(time_ <= 0.0)
        return 0.0;
    
    time_ /= duration_;
    
    if(time_ >= 1.0)
        return 1.0;
    
    CGFloat period = duration_ * 0.3;
    CGFloat s = period * 0.25;
    
    return pow(2.0, -10.0 * time_) * sin((time_ * duration_ - s) * (2.0 * M_PI) / period ) + 1.0;
}


+ (CGFloat)animationTimingFunctionElasticInOut:(CGFloat)time_ duration:(CGFloat)duration_
{
    if(time_ <= 0.0)
        return 0.0;
    
    time_ /= duration_ * 0.5;
    
    if(time_ >= 2.0)
        return 1.0;
    
    CGFloat period = duration_ * 0.3 * 1.5;
    CGFloat s = period * 0.25;
    
    time_ -= 1.0;
    
    if(time_ < 0.0)
        return -0.5 * (pow(2.0, 10.0 * time_) * sin((time_ * duration_ - s) * (2.0 * M_PI) / period));

    return pow(2.0, -10.0 * time_) * sin((time_ * duration_ - s) * (2.0 * M_PI) / period) * 0.5 + 1.0;
}

@end
