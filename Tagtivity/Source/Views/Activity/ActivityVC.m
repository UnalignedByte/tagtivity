//
//  ActivityVC.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 18.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ActivityVC.h"

#import "ActivityView.h"
#import "ActivityElement.h"

#import "ActivityManager.h"

#import "Activity.h"

#import "Utils.h"


#define INITIAL_DISTANCE_DEGREES 45.0
#define SETTINGS_DELAY 0.5


typedef enum {
    ACTIVITY_STATE_ANIMATION,
    ACTIVITY_STATE_SHOW_CURRENT,
    ACTIVITY_STATE_CHOOSE_NEW,
    ACTIVITY_STATE_SETTINGS
} ActivityState;


@interface ActivityVC ()

@property (nonatomic, assign) ActivityState state;
@property (nonatomic, weak) IBOutlet ActivityView *activityView;
@property (nonatomic, strong) NSArray *activityElements;

@property (nonatomic, assign) CGPoint chooseNewActivityCircleCenter;
@property (nonatomic, assign) CGFloat chooseNewActivityCircleDiameter;

@property (nonatomic, strong) NSTimer *settingsTimer;

@end


@implementation ActivityVC


#pragma mark - Initialization
- (id)init
{
    if((self = [super initWithNibName:@"ActivityView" bundle:nil]) == nil)
        return nil;
    
    //[[ActivityManager sharedInstance] createNewActivityWithName:@"Mucho"];

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.chooseNewActivityCircleCenter = CGPointMake(self.view.frame.size.width/2.0,
                                                     self.view.frame.size.height/2.0);
    self.chooseNewActivityCircleDiameter = 80.0;
    
    Activity *currentActivity = [[ActivityManager sharedInstance] currentActivity];
    [self setupActivityElements];
    self.activityView.chooseNewActivityCircleCenter = self.chooseNewActivityCircleCenter;
    self.activityView.chooseNewActivityCircleDiameter = self.chooseNewActivityCircleDiameter;
    
    self.state = ACTIVITY_STATE_ANIMATION;
    [self.activityView showCurrentActivity:currentActivity finished:^{
        self.state = ACTIVITY_STATE_SHOW_CURRENT;
    }];
}


- (void)setupActivityElements
{
    NSMutableArray *inactiveAcitivities = [NSMutableArray array];
    
    NSArray *activities = [[ActivityManager sharedInstance] allActivities];
    Activity *currentActivity = [[ActivityManager sharedInstance] currentActivity];
    
    for(Activity *activity in activities) {
        if(![currentActivity.name isEqualToString:activity.name])
            [inactiveAcitivities addObject:activity];
   }
    
    NSMutableArray *activityElements = [NSMutableArray array];

    if(inactiveAcitivities.count <= 0) {
        self.activityElements = [NSArray array];
        return;
    }
    
    CGFloat startAngle;
    CGFloat angleDistance;
    
    if(inactiveAcitivities.count * INITIAL_DISTANCE_DEGREES <= 360.0) {
        angleDistance = INITIAL_DISTANCE_DEGREES;
    
        if(inactiveAcitivities.count%2 == 0)
            startAngle = -((inactiveAcitivities.count - 2)*angleDistance)/2.0 - 0.5*angleDistance;
        else
            startAngle = -((inactiveAcitivities.count - 1)*angleDistance)/2.0;
    } else {
        angleDistance = 360.0/inactiveAcitivities.count;
        
        if(inactiveAcitivities.count%2 == 0)
            startAngle = -180.0;
        else
            startAngle = -180.0 + angleDistance/2.0;
    }
    
    
    
    for(int i=0; i<inactiveAcitivities.count; i++) {
        CGFloat angle = startAngle + i*angleDistance;
        ActivityElement *activityElement = [[ActivityElement alloc] initWithActivity:inactiveAcitivities[i] angle:angle];
        [activityElements addObject:activityElement];
    }
    
    
    self.activityElements =  [activityElements copy];
}


#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
    CGPoint touchLocation = [[touches_ anyObject] locationInView:self.view];
    
    switch(self.state) {
        case ACTIVITY_STATE_SHOW_CURRENT:
        {
            if([self isTouchingNewActivityCircle:touchLocation]) {
                self.state = ACTIVITY_STATE_ANIMATION;
                [self.activityView showActivityElements:self.activityElements finished:^{
                    self.state = ACTIVITY_STATE_CHOOSE_NEW;
                    
                    //If we keep finger on circle for SETTINGS_DELAY amount of time, we enter settings mode
                    self.settingsTimer = [NSTimer timerWithTimeInterval:SETTINGS_DELAY
                                                                 target:self
                                                               selector:@selector(settingsTimerFired:)
                                                               userInfo:nil
                                                                repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:self.settingsTimer forMode:NSDefaultRunLoopMode];
                }];
            }
        }
            break;
        case ACTIVITY_STATE_CHOOSE_NEW:
            break;
        case ACTIVITY_STATE_SETTINGS:
            if([self isTouchingNewActivityCircle:touchLocation]) {
                self.state = ACTIVITY_STATE_ANIMATION;
                [self.activityView showCurrentActivity:[[ActivityManager sharedInstance] currentActivity] finished:^{
                    self.state = ACTIVITY_STATE_SHOW_CURRENT;
                }];
            }
            break;
        default:
            break;
    }
}


- (void)touchesMoved:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
    CGPoint touchLocation = [[touches_ anyObject] locationInView:self.view];
    
    switch(self.state) {
        case ACTIVITY_STATE_SHOW_CURRENT:
            break;
        case ACTIVITY_STATE_CHOOSE_NEW:
        {
            if(self.settingsTimer != nil && ![self isTouchingNewActivityCircle:touchLocation]) {
                [self.settingsTimer invalidate];
                self.settingsTimer = nil;
            }
        }
            break;
        case ACTIVITY_STATE_SETTINGS:
            break;
        default:
            break;
    }
}


- (void)touchesEnded:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
    CGPoint touchLocation = [[touches_ anyObject] locationInView:self.view];

    switch(self.state) {
        case ACTIVITY_STATE_SHOW_CURRENT:
            break;
        case ACTIVITY_STATE_CHOOSE_NEW:
        {
            if(self.settingsTimer != nil) {
                [self.settingsTimer invalidate];
                self.settingsTimer = nil;
            }

            for(ActivityElement *activityElement in self.activityElements) {
                if([activityElement isTouching:touchLocation]) {
                    [[ActivityManager sharedInstance] startActivity:[activityElement associatedActivity]];
                    break;
                }
            }

            self.state = ACTIVITY_STATE_ANIMATION;
            [self.activityView showCurrentActivity:[[ActivityManager sharedInstance] currentActivity] finished:^{
                self.state = ACTIVITY_STATE_SHOW_CURRENT;
            }];
            
            [self setupActivityElements];
        }
            break;
        default:
            break;
    }
}


- (void)touchesCancelled:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
    [self touchesEnded:touches_ withEvent:event_];
}


#pragma mark - Handle Timers
- (void)settingsTimerFired:(NSTimer *)timer_
{
    self.state = ACTIVITY_STATE_ANIMATION;
    [self.activityView showSettings:^{
        self.state = ACTIVITY_STATE_SETTINGS;
    }];
}
                
                
#pragma mark - Utils
- (BOOL)isTouchingNewActivityCircle:(CGPoint)touchLocation_
{
    CGFloat distance = [Utils distanceBetweenPointA:touchLocation_ pointB:self.chooseNewActivityCircleCenter];
    if(distance <= self.chooseNewActivityCircleDiameter/2.0)
        return YES;
    
    return NO;
}

@end
