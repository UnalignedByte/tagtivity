//
//  ActivityVC.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 18.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ActivityVC.h"

#import "ActivityView.h"
#import "ChooseActivityElement.h"
#import "ActivityElement.h"
#import "SettingsElement.h"
#import "AddNewActivityElement.h"

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

@property (nonatomic, weak) IBOutlet ActivityView *activityView;

@property (nonatomic, assign) ActivityState state;

@property (nonatomic, strong) ChooseActivityElement *chooseActivityElement;
@property (nonatomic, strong) NSArray *activityElements;
@property (nonatomic, strong) SettingsElement *settingsElement;
@property (nonatomic, strong) AddNewActivityElement *addNewActivityElement;

//SETTINGS STATE
@property (nonatomic, strong) NSTimer *settingsTimer;
@property (nonatomic, strong) ActivityElement *selectedActivityElement;
@property (nonatomic, assign) BOOL isEditingActivityElement;
@property (nonatomic, assign) BOOL isMovingActivityElement;

@end


@implementation ActivityVC


#pragma mark - Initialization
- (id)init
{
    if((self = [super initWithNibName:@"ActivityView" bundle:nil]) == nil)
        return nil;

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*[[ActivityManager sharedInstance] createNewActivityWithName:@"Coś"];
    [[ActivityManager sharedInstance] createNewActivityWithName:@"Nic"];
    [[ActivityManager sharedInstance] createNewActivityWithName:@"Jedzenie"];
    [[ActivityManager sharedInstance] createNewActivityWithName:@"Jajo"];*/
 
    self.chooseActivityElement = [[ChooseActivityElement alloc] init];
    [self setupActivityElements];
    self.settingsElement = [[SettingsElement alloc] init];
    self.addNewActivityElement = [[AddNewActivityElement alloc] init];

    Activity *currentActivity = [[ActivityManager sharedInstance] currentActivity];

    self.state = ACTIVITY_STATE_ANIMATION;
    [self.activityView showCurrentActivity:currentActivity chooseActivityElement:self.chooseActivityElement finished:^{
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
            if([self.chooseActivityElement isTouching:touchLocation]) {
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
        {
        }
            break;
        case ACTIVITY_STATE_SETTINGS:
        {
            if([self.chooseActivityElement isTouching:touchLocation] && !self.isEditingActivityElement && !self.isMovingActivityElement) {
                self.state = ACTIVITY_STATE_ANIMATION;
                [self.activityView showCurrentActivity:[[ActivityManager sharedInstance] currentActivity]
                                 chooseActivityElement:self.chooseActivityElement
                                              finished:^{
                    self.state = ACTIVITY_STATE_SHOW_CURRENT;
                }];
            } else {
                for(ActivityElement *activityElement in self.activityElements) {
                    if([activityElement isTouching:touchLocation]) {
                        self.selectedActivityElement = activityElement;
                        break;
                    }
                }
            }
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
        {
            
        }
            break;
        case ACTIVITY_STATE_CHOOSE_NEW:
        {
            if(self.settingsTimer != nil && ![self.chooseActivityElement isTouching:touchLocation]) {
                [self.settingsTimer invalidate];
                self.settingsTimer = nil;
            }
        }
            break;
        case ACTIVITY_STATE_SETTINGS:
        {
            if(self.selectedActivityElement != nil && !self.isEditingActivityElement) {
                self.isMovingActivityElement = YES;
                [self moveSelectedActivityToAngle:[Utils angleOfPoint:touchLocation]];
                [self recalculateActivityElementsIgnoringSelected:YES];
            }
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


- (void)touchesEnded:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
    CGPoint touchLocation = [[touches_ anyObject] locationInView:self.view];

    switch(self.state) {
        case ACTIVITY_STATE_SHOW_CURRENT:
        {
            
        }
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
            [self.activityView showCurrentActivity:[[ActivityManager sharedInstance] currentActivity]
                             chooseActivityElement:self.chooseActivityElement
                                          finished:^{
                self.state = ACTIVITY_STATE_SHOW_CURRENT;
            }];
            
            [self setupActivityElements];
        }
            break;
        case ACTIVITY_STATE_SETTINGS:
        {
            if(self.selectedActivityElement != nil && !self.isMovingActivityElement) {
                self.isEditingActivityElement = YES;
            } else if(self.selectedActivityElement != nil && self.isMovingActivityElement) {
                self.isMovingActivityElement = NO;
                self.selectedActivityElement = nil;
                [self recalculateActivityElementsIgnoringSelected:NO];
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - Handle Timers
- (void)settingsTimerFired:(NSTimer *)timer_
{
    self.state = ACTIVITY_STATE_ANIMATION;
    [self.activityView showSettings:self.settingsElement addNewActivityElement:self.addNewActivityElement
                           finished:^{
                               self.state = ACTIVITY_STATE_SETTINGS;
                           }];
}


#pragma mark - Settings
- (void)moveSelectedActivityToAngle:(CGFloat)angle_
{
    self.selectedActivityElement.angle = angle_;
    [self.activityView redraw];
}


- (void)recalculateActivityElementsIgnoringSelected:(BOOL)isIgnoringSelected_
{
    //recalculate indexes
    NSArray *activitiesSortedByAngle = [self.activityElements sortedArrayUsingSelector:@selector(compareByAngle:)];
    
    NSMutableArray *activitiesToReindex = [NSMutableArray array];
    for(ActivityElement *activityElement in activitiesSortedByAngle) {
        [activitiesToReindex addObject:[activityElement associatedActivity]];
    }
    Activity *currentActivity = [[ActivityManager sharedInstance] currentActivity];
    [activitiesToReindex insertObject:currentActivity atIndex:currentActivity.index.integerValue];
    
    for(NSInteger i=0; i<activitiesToReindex.count; i++) {
        Activity *activity = activitiesToReindex[i];
        activity.index = @(i);
    }
    
    //calculate new angles    
    CGFloat startAngle;
    CGFloat angleDistance;
    
    if(activitiesSortedByAngle.count * INITIAL_DISTANCE_DEGREES <= 360.0) {
        angleDistance = INITIAL_DISTANCE_DEGREES;
        
        if(activitiesSortedByAngle.count%2 == 0)
            startAngle = -((activitiesSortedByAngle.count - 2)*angleDistance)/2.0 - 0.5*angleDistance;
        else
            startAngle = -((activitiesSortedByAngle.count - 1)*angleDistance)/2.0;
    } else {
        angleDistance = 360.0/activitiesSortedByAngle.count;
        
        if(activitiesSortedByAngle.count%2 == 0)
            startAngle = -180.0;
        else
            startAngle = -180.0 + angleDistance/2.0;
    }

    for(int i=0; i<activitiesSortedByAngle.count; i++) {
        CGFloat angle = startAngle + i*angleDistance;
        ActivityElement *activityElement = activitiesSortedByAngle[i];
        activityElement.newAngle = angle;
    }
    
    //create array of activities to move
    NSMutableArray *activitiesToMove = [NSMutableArray array];
    for(ActivityElement *activityElement in self.activityElements) {
        if(!isIgnoringSelected_ || ![activityElement isEqual:self.selectedActivityElement]) {
            [activitiesToMove addObject:activityElement];
        }
    }
    
    [self.activityView moveActivityElementsToNewAngle:activitiesToMove];
}

@end
