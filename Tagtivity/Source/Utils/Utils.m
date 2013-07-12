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

@end
