//
//  ActivityVC.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 18.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ActivityVC.h"

#import "ActivityView.h"

#import "ActivityManager.h"


@interface ActivityVC ()

@property (nonatomic, weak) IBOutlet ActivityView *activityView;

@end


@implementation ActivityVC

- (id)init
{
    if((self = [super initWithNibName:@"ActivityView" bundle:nil]) == nil)
        return nil;

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Activity *currentActivity = [[ActivityManager sharedInstance] currentActivity];
    [self.activityView showCurrentActivity:currentActivity finished:^{
    }];
}


#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
}


- (void)touchesMoved:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
}


- (void)touchesEnded:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
}


- (void)touchesCancelled:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
}

@end
