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

//Modify Data
- (Activity *)createNewActivityWithName:(NSString *)activityName_;
- (void)deleteActivity:(Activity *)activity_;
- (void)startActivity:(Activity *)activity_;
- (void)stopActivity:(Activity *)activity_;

//Query Data
- (NSArray *)getAllActivities;
- (Activity *)getCurrentActivity;
- (Activity *)getUndefinedActivity;
- (NSArray *)getInactiveActivities;
- (Activity *)getActivityWithName:(NSString *)activityName_;

@end
