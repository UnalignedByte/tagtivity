//
//  StatsOverviewCell.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 09.11.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString *kStatsOverviewCellIdentifier = @"StatsOverviewCellIdentifier";
#pragma unused(kNoteCellIdentifier)


@interface StatsOverviewCell : UITableViewCell

//Initialization
- (id)init;
- (void)configureWithName:(NSString *)name_ duration:(NSInteger)duration_ percentage:(CGFloat)percentage_;

//Class  Info
+ (CGFloat)height;

@end
