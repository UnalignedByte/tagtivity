//
//  StatsOverviewCell.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 09.11.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "StatsOverviewCell.h"


static NSInteger kSecondsInMinute = 60;
static NSInteger kSecondsInHour   = 60 * 60;
static NSInteger kSecondsInDay    = 60 * 60 * 24;


@interface StatsOverviewCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UILabel *percentageLabel;

@end


@implementation StatsOverviewCell

#pragma mark - Initialization
- (id)init
{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"StatsOverviewCell" owner:nil options:nil];
    StatsOverviewCell *cell = nibObjects[0];
    
    return cell;
}


- (void)configureWithName:(NSString *)name_ duration:(NSInteger)duration_ percentage:(CGFloat)percentage_
{
    self.nameLabel.text = name_;
    
    NSNumberFormatter *percentageFormatter = [[NSNumberFormatter alloc] init];
    percentageFormatter.minimumIntegerDigits = 1;
    percentageFormatter.maximumIntegerDigits = 3;
    percentageFormatter.minimumFractionDigits = 2;
    percentageFormatter.maximumFractionDigits = 2;
    
    NSInteger days = duration_/kSecondsInDay;
    NSInteger hours = (duration_%kSecondsInDay)/kSecondsInHour;
    NSInteger minutes = (duration_%kSecondsInHour)/kSecondsInMinute;
    NSInteger seconds = (duration_%kSecondsInMinute);
    
    //Duration
    NSMutableString *durationString = [NSMutableString string];
    if(days > 0)
        [durationString appendString:[NSString stringWithFormat:@"%d days ", days]];
    [durationString appendString:[NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds]];
    self.durationLabel.text = durationString;
    
    //Percentage
    NSString *percentageString = [percentageFormatter stringFromNumber:@(percentage_)];
    percentageString = [NSString stringWithFormat:@"%@%%", percentageString];
    self.percentageLabel.text = percentageString;
}


#pragma mark - Class  Info
+ (CGFloat)height
{
    static StatsOverviewCell *cell;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"StatsOverviewCell" owner:nil options:nil];
        cell = nibObjects[0];
    });
    
    return cell.frame.size.height;
}

@end
