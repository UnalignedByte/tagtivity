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
@property (nonatomic, strong) NSMutableArray *activityElements;
@property (nonatomic, strong) SettingsElement *settingsElement;
@property (nonatomic, strong) AddNewActivityElement *addNewActivityElement;

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
    self.addNewActivityElement = [[AddNewActivityElement alloc] init];

    Activity *currentActivity = [[ActivityManager sharedInstance] currentActivity];

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
                [self.activityView showCurrentActivity:[[ActivityManager sharedInstance] currentActivity]
                                 chooseActivityElement:self.chooseActivityElement
                                              finished:^{
                    self.state = ACTIVITY_STATE_SHOW_CURRENT;
                }];
            } else if([self.addNewActivityElement isTouching:touchLocation] && !self.isEditingActivityElement &&
                      !self.isMovingActivityElement) {
                self.isAdding = YES;
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
                [self calculateActivityElementsIgnoringSelected:YES];
            } else if(self.isAdding) {
                if([self.addNewActivityElement touchedAtLocation:touchLocation]) {
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
                [self calculateActivityElementsIgnoringSelected:NO];
            } else if(self.isAdding) {
                [self.addNewActivityElement cancel];
                self.isAdding = NO;
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


- (void)calculateActivityElementsIgnoringSelected:(BOOL)isIgnoringSelected_
{
    //Recalculate indexes
    NSArray *activityElementsSortedByAngle = [self.activityElements sortedArrayUsingSelector:@selector(compareByAngle:)];
    
    NSMutableArray *activitiesToReindex = [NSMutableArray array];
    for(ActivityElement *activityElement in activityElementsSortedByAngle) {
        [activitiesToReindex addObject:[activityElement associatedActivity]];
    }
    Activity *currentActivity = [[ActivityManager sharedInstance] currentActivity];
    [activitiesToReindex insertObject:currentActivity atIndex:currentActivity.index.integerValue];
    
    for(NSInteger i=0; i<activitiesToReindex.count; i++) {
        Activity *activity = activitiesToReindex[i];
        activity.index = @(i);
    }
    
    //Recalculate angles    
    [self calculateAnglesForActivityElements:activityElementsSortedByAngle shouldAnimate:NO
                     ignoringActivityElement:isIgnoringSelected_ ? self.selectedActivityElement : nil];
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
