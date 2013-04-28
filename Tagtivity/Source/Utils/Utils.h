//
//  Utils.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 28.04.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject

//Control
+ (void)handleError:(NSError *)error_;
+ (void)createDirectoryIfNecessary:(NSURL *)url_;

@end
