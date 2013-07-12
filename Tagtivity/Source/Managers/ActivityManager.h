//
//  ActivityManager.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 28.04.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Activity;


@interface ActivityManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *activitiesContext;


//Initialization
+ (ActivityManager *)sharedInstance;

//Control
- (Activity *)createNewActivityWithName:(NSString *)activityName_;
- (void)deleteActivity:(Activity *)activity_;
- (Activity *)undefinedActivity;
- (Activity *)currentActivity;
- (NSArray *)allActivities;
- (void)startActivity:(Activity *)activity_;
- (void)stopActivity:(Activity *)activity_;

@end
