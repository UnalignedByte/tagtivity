//
//  ActivityVC.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 18.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ActivityVC.h"

#import "ActivityView.h"
#import "ActivitySettingsView.h"
#import "ChooseActivityElement.h"
#import "ActivityElement.h"
#import "SettingsElement.h"
#import "AddOrDeleteActivityElement.h"

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
@property (nonatomic, strong) IBOutlet ActivitySettingsView *activitySettingsView;

@property (nonatomic, assign) ActivityState state;

@property (nonatomic, strong) ChooseActivityElement *chooseActivityElement;
@property (nonatomic, strong) NSMutableArray *activityElements;
@property (nonatomic, strong) SettingsElement *settingsElement;
@property (nonatomic, strong) AddOrDeleteActivityElement *addOrDeleteActivityElement;

//SETTINGS STATE
@property (nonatomic, strong) NSTimer *settingsTimer;
@property (nonatomic, strong) ActivityElement *selectedActivityElement;
@property (nonatomic, assign) BOOL isEditingActivityElement;
@property (nonatomic, assign) BOOL isMovingActivityElement;
@property (nonatomic, assign) BOOL isAdding;

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

    self.chooseActivityElement = [[ChooseActivityElement alloc] init];
    [self setupActivityElements];
    self.settingsElement = [[SettingsElement alloc] init];
    self.addOrDeleteActivityElement = [[AddOrDeleteActivityElement alloc] init];
    
    self.activitySettingsView = [[ActivitySettingsView alloc] init];
    [self.view addSubview:self.activitySettingsView];
    
    [self setupEventHandlers];

    Activity *currentActivity = [[ActivityManager sharedInstance] getCurrentActivity];
    self.state = ACTIVITY_STATE_ANIMATION;
    [self.activityView showCurrentActivity:currentActivity chooseActivityElement:self.chooseActivityElement finished:^{
        self.state = ACTIVITY_STATE_SHOW_CURRENT;
    }];
}


- (void)setupActivityElements
{
    NSArray *inactiveAcitivities = [[ActivityManager sharedInstance] getInactiveActivities];

    self.activityElements = [NSMutableArray array];
    
    for(int i=0; i<inactiveAcitivities.count; i++) {
        ActivityElement *activityElement = [[ActivityElement alloc] initWithActivity:inactiveAcitivities[i] angle:0.0];
        [self.activityElements addObject:activityElement];
    }
    
    [self calculateAnglesForActivityElements:self.activityElements shouldAnimate:NO ignoringActivityElement:nil];
}


- (void)setupEventHandlers
{
    __weak typeof(self) weakSelf = self;
    [self.activitySettingsView addOnHideEventHandler:^{
        [weakSelf settingViewClosed];
    }];
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
            if([self.chooseActivityElement isTouching:touchLocation] && !self.isEditingActivityElement && !self.isMovingActivityElement
               && !self.isAdding) {
                self.state = ACTIVITY_STATE_ANIMATION;
                [self.activityView showCurrentActivity:[[ActivityManager sharedInstance] getCurrentActivity]
                                 chooseActivityElement:self.chooseActivityElement
                                              finished:^{
                    self.state = ACTIVITY_STATE_SHOW_CURRENT;
                }];
            } else if([self.addOrDeleteActivityElement isTouching:touchLocation] && !self.isEditingActivityElement &&
                      !self.isMovingActivityElement) {
                self.isAdding = YES;
            } else {
                //start dragging an element
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
                [self calculateActivityElementsIgnoringSelected:YES];
            } else if(self.isAdding) {
                if([self.addOrDeleteActivityElement isTouchingAddLocation:touchLocation]) {
                    Activity *activity = [[ActivityManager sharedInstance] createNewActivityWithName:@"New"];
                    ActivityElement *activityElement = [[ActivityElement alloc] initWithActivity:activity angle:[Utils angleOfPoint:touchLocation]];
                    self.selectedActivityElement = activityElement;
                    self.isAdding = NO;
                    self.isMovingActivityElement = YES;
                    self.isEditingActivityElement = NO;
                    [self.activityElements addObject:activityElement];
                    [self calculateActivityElementsIgnoringSelected:YES];
                }
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
            [self.activityView showCurrentActivity:[[ActivityManager sharedInstance] getCurrentActivity]
                             chooseActivityElement:self.chooseActivityElement
                                          finished:^{
                self.state = ACTIVITY_STATE_SHOW_CURRENT;
            }];
            
            [self setupActivityElements];
        }
            break;
        case ACTIVITY_STATE_SETTINGS:
        {
            if([self shouldStartEditingSelectedActivityElement]) {
                [self startEditingSelectedActivityElement];
            } if([self shouldDeleteSelectedActivityElement:touchLocation]) {
                [self deleteSelectedActivityElement];
            } else if([self shouldStopMovingSelectedActivityElement]) {
                [self stopMovingSelectedActivityElement];
            } else if([self shouldCancelAddingNewActivity]) {
                [self cancelAddingActivityElement];
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
    [self.activityView showSettings:self.settingsElement addOrDeleteActivityElement:self.addOrDeleteActivityElement
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


- (void)calculateActivityElementsIgnoringSelected:(BOOL)isIgnoringSelected_
{
    //Recalculate indexes
    NSArray *activityElementsSortedByAngle = [self.activityElements sortedArrayUsingSelector:@selector(compareByAngle:)];
    
    NSMutableArray *activitiesToReindex = [NSMutableArray array];
    for(ActivityElement *activityElement in activityElementsSortedByAngle) {
        [activitiesToReindex addObject:[activityElement associatedActivity]];
    }
    Activity *currentActivity = [[ActivityManager sharedInstance] getCurrentActivity];
    if(currentActivity.index.integerValue <= activitiesToReindex.count)
        [activitiesToReindex insertObject:currentActivity atIndex:currentActivity.index.integerValue];
    else
        [activitiesToReindex addObject:currentActivity];
    
    for(NSInteger i=0; i<activitiesToReindex.count; i++) {
        Activity *activity = activitiesToReindex[i];
        activity.index = @(i);
    }
    
    //Recalculate angles    
    [self calculateAnglesForActivityElements:activityElementsSortedByAngle shouldAnimate:NO
                     ignoringActivityElement:isIgnoringSelected_ ? self.selectedActivityElement : nil];
}


#pragma mark - Settings State Conditions
- (BOOL)shouldStartEditingSelectedActivityElement
{
    return self.selectedActivityElement != nil && !self.isMovingActivityElement;
}


- (BOOL)shouldDeleteSelectedActivityElement:(CGPoint)touchLocation_
{
    return self.selectedActivityElement != nil &&
    [self.addOrDeleteActivityElement isTouchingDeleteLocation:touchLocation_];
}


- (BOOL)shouldStopMovingSelectedActivityElement
{
    return self.selectedActivityElement != nil && self.isMovingActivityElement;
}


- (BOOL)shouldCancelAddingNewActivity
{
    return self.isAdding;
}


#pragma mark - Settings State Actions
- (void)startEditingSelectedActivityElement
{
    self.isEditingActivityElement = YES;
    [self.activitySettingsView configureWithActivity:[self.selectedActivityElement associatedActivity]];
    [self.activitySettingsView show];
}


- (void)deleteSelectedActivityElement
{
    [self.activityElements removeObject:self.selectedActivityElement];
    [[ActivityManager sharedInstance] deleteActivity:[self.selectedActivityElement associatedActivity]];
    self.selectedActivityElement = nil;
    self.isMovingActivityElement = NO;
    [self calculateActivityElementsIgnoringSelected:NO];
}


- (void)stopMovingSelectedActivityElement
{
    self.isMovingActivityElement = NO;
    self.selectedActivityElement = nil;
    [self calculateActivityElementsIgnoringSelected:NO];
}


- (void)cancelAddingActivityElement
{
    self.isAdding = NO;
}


#pragma mark - Event Handlers
- (void)settingViewClosed
{
    self.isEditingActivityElement = NO;
    [self.activityView redraw];
}


#pragma mark - Utils
- (void)calculateAnglesForActivityElements:(NSArray *)activityElements_ shouldAnimate:(BOOL)shouldAnimate_
                   ignoringActivityElement:(ActivityElement *)ignoredActivityElement_
{
    CGFloat startAngle;
    CGFloat angleDistance;
    
    if(activityElements_.count * INITIAL_DISTANCE_DEGREES <= 360.0) {
        angleDistance = INITIAL_DISTANCE_DEGREES;
        
        if(activityElements_.count%2 == 0)
            startAngle = -((activityElements_.count - 2)*angleDistance)/2.0 - 0.5*angleDistance;
        else
            startAngle = -((activityElements_.count - 1)*angleDistance)/2.0;
    } else {
        angleDistance = 360.0/activityElements_.count;
        
        if(activityElements_.count%2 == 0)
            startAngle = -180.0;
        else
            startAngle = -180.0 + angleDistance/2.0;
    }
    
    for(int i=0; i<activityElements_.count; i++) {
        CGFloat angle = startAngle + i*angleDistance;
        ActivityElement *activityElement = activityElements_[i];
        
        if(ignoredActivityElement_ == nil || ![ignoredActivityElement_ isEqual:activityElement]) {
            if(shouldAnimate_)
                activityElement.newAngle = angle;
            else
                activityElement.angle = angle;
       }
    }
    
    if(shouldAnimate_) {
        NSMutableArray *activityElementsToAnimate = [NSMutableArray array];
        for(ActivityElement *activityElement in activityElements_) {
            if(ignoredActivityElement_ == nil || ![ignoredActivityElement_ isEqual:activityElement])
                [activityElementsToAnimate addObject:activityElement];
        }
        
        [self.activityView moveActivityElementsToNewAngle:activityElementsToAnimate];
    } else {
        [self.activityView redraw];
    }
}

@end
