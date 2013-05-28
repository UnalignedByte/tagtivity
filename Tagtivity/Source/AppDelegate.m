//
//  AppDelegate.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 23.04.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "AppDelegate.h"

#import "ActivityVC.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[ActivityVC alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
