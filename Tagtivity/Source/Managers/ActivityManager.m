//
//  ActivityManager.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 28.04.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ActivityManager.h"

#import "Activity.h"
#import "ActivityInstance.h"

#import "Utils.h"


#define DEFAULT_ACTIVITY_IMAGE_FILENAME @"default.png"


@interface ActivityManager()

@property (nonatomic, strong) NSManagedObjectModel *activitiesModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *activitiesStoreCoordinator;

@end


@implementation ActivityManager

#pragma mark - Initialization
+ (ActivityManager *)sharedInstance
{
    static ActivityManager *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [[ActivityManager alloc] init];
    });
    
    return sharedInstance;
}


- (id)init
{
    if((self = [super init]) == nil)
        return nil;
    
    [self setupActivitiesModel];
    [self setupActivitiesStoreCoordinator];
    [self setupActivitiesContext];
    [self setupCoreDataObservers];
    [self getUndefinedActivity];
    
    return self;
}


- (void)setupCoreDataObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(activitiesContextChanged:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:_activitiesContext];
}


- (void)setupActivitiesModel
{
    NSURL *activitiesModelUrl = [[NSBundle mainBundle] URLForResource:@"Activities" withExtension:@"momd"];
    self.activitiesModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:activitiesModelUrl];
}


- (void)setupActivitiesStoreCoordinator
{
    NSError *error;
    
    NSURL *storeUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                              inDomains:NSUserDomainMask] lastObject];
    storeUrl = [storeUrl URLByAppendingPathComponent:@"activities.sqlite"];
    [Utils createDirectoryIfNecessary:storeUrl];
    
    self.activitiesStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.activitiesModel];
    
    [self.activitiesStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeUrl
                                                        options:nil
                                                          error:&error];
    [Utils handleError:error];
}


- (void)setupActivitiesContext
{
    _activitiesContext = [[NSManagedObjectContext alloc] init];
    [_activitiesContext setPersistentStoreCoordinator:self.activitiesStoreCoordinator];
}


#pragma mark - CoreData events
- (void)activitiesContextChanged:(NSNotification *)notification_
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        
        [_activitiesContext save:&error];
        [Utils handleError:error];
    });
}


#pragma mark - Modify Data
- (Activity *)createNewActivityWithName:(NSString *)activityName_
{
    NSString *activityName = activityName_;
    
    NSInteger num=2;
    while([self getActivityWithName:activityName] != nil) {
        activityName = [NSString stringWithFormat:@"%@ %d", activityName_, num];
        num++;
    }
    
    Activity *activity = [NSEntityDescription insertNewObjectForEntityForName:@"Activity"
                                                       inManagedObjectContext:_activitiesContext];
    activity.name = activityName;
    activity.totalDuration = @0;
    activity.isActive = @NO;
    activity.imageFilename = DEFAULT_ACTIVITY_IMAGE_FILENAME;
    activity.instances = nil;
    activity.index = @([self getMaxIndex]+1);
    
    return activity;
}


- (void)deleteActivity:(Activity *)activity_
{
    [_activitiesContext deleteObject:activity_];
}


- (void)startActivity:(Activity *)activity_
{
    Activity *activeActivity = [self getCurrentActivity];
    
    //no point in starting again the same activity
    if(activeActivity != nil && [activeActivity isEqual:activity_])
        return;
    
    if(activeActivity != nil)
        [self stopActivity:activeActivity];
    
    activity_.isActive = @YES;
    ActivityInstance *activityInstance = [self createNewActivityInstance];
    [activity_ addInstancesObject:activityInstance];
}


- (void)stopActivity:(Activity *)activity_
{
    for(ActivityInstance *activityInstance in activity_.instances)
        if(activityInstance.duration.integerValue == -1) {
            NSInteger activityDuration = [[NSDate date] timeIntervalSinceDate:activityInstance.startDate];
            activityDuration /= 1000; //timeIntervalSinceDate returns time in milliseconds, we're interested in seconds
            activityInstance.duration = [NSNumber numberWithInteger:activityDuration];
            activity_.totalDuration = [NSNumber numberWithInteger:activityDuration + activity_.totalDuration.integerValue];
            break;
        }
    
    activity_.isActive = @NO;
}


#pragma mark - Query Data
- (NSArray *)getAllActivities
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Activity"
                                      inManagedObjectContext:_activitiesContext];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
    
    NSArray *activities = [_activitiesContext executeFetchRequest:fetchRequest error:&error];
    [Utils handleError:error];
    
    if(activities.count > 0)
        return activities;
    
    return @[[self getUndefinedActivity]];
}


- (Activity *)getCurrentActivity
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Activity"
                                      inManagedObjectContext:_activitiesContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isActive == %@", @YES]];
    
    NSArray *activeActivities = [_activitiesContext executeFetchRequest:fetchRequest error:&error];
    [Utils handleError:error];
    
    if(activeActivities.count == 1)
        return activeActivities[0];
    
    //there should be only one active activity
    if(activeActivities.count > 0) {
        for(Activity *activity in activeActivities)
            [self stopActivity:activity];
    }
    
    Activity *undefinedActivity = [self getUndefinedActivity];
    
    return undefinedActivity;
}


- (Activity *)getUndefinedActivity
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Activity"
                                      inManagedObjectContext:_activitiesContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", @"Undefined"];
    
    NSArray *undefinedActivities = [_activitiesContext executeFetchRequest:fetchRequest error:&error];
    [Utils handleError:error];
    
    Activity *undefinedActivity;
    if(undefinedActivities.count > 0) {
        undefinedActivity = undefinedActivities[0];
    } else {
        undefinedActivity = [self createNewActivityWithName:@"Undefined"];
    }
    
    return undefinedActivity;
}


- (NSArray *)getInactiveActivities
{
    NSMutableArray *inactiveAcitivities = [NSMutableArray array];
    NSArray *activities = [self getAllActivities];
    Activity *currentActivity = [[ActivityManager sharedInstance] getCurrentActivity];
    
    for(Activity *activity in activities) {
        if(![currentActivity.name isEqualToString:activity.name])
            [inactiveAcitivities addObject:activity];
    }
    
    return inactiveAcitivities;
}


- (Activity *)getActivityWithName:(NSString *)activityName_
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Activity"
                                      inManagedObjectContext:_activitiesContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name=%@", activityName_];
    
    NSArray *activities = [_activitiesContext executeFetchRequest:fetchRequest error:&error];
    [Utils handleError:error];
    
    if(activities.count > 0)
        return activities[0];
    
    return nil;
}


#pragma mark - Control Activity Instance
- (ActivityInstance *)createNewActivityInstance
{
    ActivityInstance *activityInstance = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityInstance" inManagedObjectContext:_activitiesContext];
    activityInstance.startDate = [NSDate date];
    activityInstance.duration = @(-1);
    
    return activityInstance;
}


- (void)deleteActivityInstance:(ActivityInstance *)activityInstance_
{
    [_activitiesContext deleteObject:activityInstance_];
}


#pragma mark - Utils
- (NSInteger)getMaxIndex
{
    NSInteger maxIndex = -1;
    
    NSArray *activities = [self getAllActivities];
    for(Activity *activity in activities) {
        if(activity.index.integerValue > maxIndex)
            maxIndex = activity.index.integerValue;
    }
    
    return maxIndex;
}


- (void)normalizeIndexes
{
    NSArray *activities = [self getAllActivities];
    for(NSInteger i=0; i<activities.count; i++) {
        ((Activity *)activities[0]).index = @(i);
    }
}

@end
