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


+ (CGFloat)angleOfPoint:(CGPoint)point_
{
    CGSize viewSize = [Utils viewSize];
    CGPoint viewCenter = CGPointMake(viewSize.width/2.0, viewSize.height/2.0);
    
    CGFloat hypotenuseDistance = [Utils distanceBetweenPointA:viewCenter pointB:point_];
    CGFloat verticalDistance = abs(point_.y - viewCenter.y);
    CGFloat sinus = verticalDistance/hypotenuseDistance;
    
    CGFloat angle = DEG(asin(sinus));
    
    BOOL isUpperHalf = point_.y < viewCenter.y;
    BOOL isRightHalf = point_.x > viewCenter.x;
    
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

@end
