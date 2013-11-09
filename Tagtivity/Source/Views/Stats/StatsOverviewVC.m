//
//  StatsOverviewVC.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 09.11.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "StatsOverviewVC.h"

#import "StatsOverviewCell.h"
#import "ActivityManager.h"
#import "Activity.h"


typedef enum {
    StatsOverviewTotalRow,
    StatsOverviewRowsCount
} StatsOverviewRow;


@interface StatsOverviewVC ()

@property (nonatomic, strong) NSArray *activities;

@end


@implementation StatsOverviewVC

#pragma mark - Initialization
- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self == nil)
        return nil;
    
    self.title = Localize(@"Overview");
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.clearsContextBeforeDrawing = NO;
}


- (void)viewWillAppear:(BOOL)animated_
{
    [super viewWillAppear:animated_];
    
    self.activities = [self sortedListOfActivityInfos];
}


#pragma mark - Internal Control
- (NSArray *)sortedListOfActivityInfos
{
    NSMutableArray *activityInfos = [NSMutableArray array];
    
    NSArray *allAcitvities = [[ActivityManager sharedInstance] getAllActivities];
    NSArray *allActivitiesSorted = [allAcitvities sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Activity *activityA = obj1;
        Activity *activityB = obj2;
        
        if(activityA.totalDuration == activityB.totalDuration)
            return NSOrderedSame;

        if(activityA.totalDuration < activityB.totalDuration)
            return NSOrderedAscending;
        
        return NSOrderedDescending;
    }];
    
    CGFloat totalDuration = 0.0;
    for(Activity *activity in allActivitiesSorted) {
        totalDuration += activity.totalDuration.doubleValue;
    }
    
    for(Activity *activity in allActivitiesSorted) {
        CGFloat percentage;
        if(totalDuration == 0.0)
            percentage = 0.0;
        else
            percentage = (activity.totalDuration.doubleValue*100.0)/totalDuration;
        NSArray *activityInfo = @[activity.name,
                                  activity.totalDuration,
                                  @(percentage)];
        [activityInfos addObject:activityInfo];
    }
    
    return activityInfos;
}


#pragma mark - Table View Delegate & Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView_
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section_
{
    return self.activities.count;
}


- (CGFloat)tableView:(UITableView *)tableView_ heightForRowAtIndexPath:(NSIndexPath *)indexPath_
{
    return [StatsOverviewCell height];
}


- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath_
{
    StatsOverviewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:kStatsOverviewCellIdentifier];
    if(cell == nil)
        cell = [[StatsOverviewCell alloc] init];
    
    NSString *name = self.activities[indexPath_.row][0];
    NSNumber *duration = self.activities[indexPath_.row][1];
    NSNumber *percentage = self.activities[indexPath_.row][2];
    
    [cell configureWithName:name duration:duration.doubleValue percentage:percentage.doubleValue];

    return cell;
}

@end
