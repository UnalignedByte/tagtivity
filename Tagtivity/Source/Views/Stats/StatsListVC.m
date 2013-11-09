//
//  StatsListVC.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 09.11.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "StatsListVC.h"

#import "StatsOverviewVC.h"


static NSString *kStatsListCellIdent = @"StatsListCellIdent";


@interface StatsListVC ()

@property (nonatomic, strong) NSArray *listEntries;

@end


@implementation StatsListVC

#pragma mark - Initialization
- (id)init
{
    self = [super init];
    self = [super initWithNibName:@"StatsListView" bundle:nil];
    if(self == nil)
        return nil;
    
    StatsOverviewVC *statsOverviewVC = [[StatsOverviewVC alloc] init];
    self.listEntries = @[@[statsOverviewVC.title, statsOverviewVC]];
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = Localize(@"Statistics");
}


#pragma mark - Table View Delegate & Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView_
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section_
{
    return self.listEntries.count;
}


- (CGFloat)tableView:(UITableView *)tableView_ heightForRowAtIndexPath:(NSIndexPath *)indexPath_
{
    return 60.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath_
{
    UITableViewCell *cell;
    cell = [tableView_ dequeueReusableCellWithIdentifier:kStatsListCellIdent];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStatsListCellIdent];
    
    cell.textLabel.text = self.listEntries[indexPath_.row][0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath_
{
    [tableView_ deselectRowAtIndexPath:indexPath_ animated:YES];

    UIViewController *statsDetailsVc = self.listEntries[indexPath_.row][1];
    [self.navigationController pushViewController:statsDetailsVc animated:YES];
}

@end
