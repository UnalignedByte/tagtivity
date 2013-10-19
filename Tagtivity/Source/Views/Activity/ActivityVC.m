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
#import "AddActivityElement.h"
#import "SliceElement.h"

#import "ActivityManager.h"

#import "Activity.h"

#import "Utils.h"


#define INITIAL_DISTANCE_DEGREES 45.0
#define SETTINGS_DELAY 1.0
#define SLICE_TIME 0.2


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
@property (nonatomic, strong) AddActivityElement *addActivityElement;
@property (nonatomic, strong) SliceElement *sliceElement;

//SETTINGS STATE
@property (nonatomic, strong) NSTimer *settingsTimer;
@property (nonatomic, strong) NSTimer *slicingTimer;
@property (nonatomic, strong) ActivityElement *selectedActivityElement;
@property (nonatomic, assign) BOOL isEditingActivityElement;
@property (nonatomic, assign) BOOL isMovingActivityElement;
@property (nonatomic, assign) BOOL isAdding;
@property (nonatomic, assign) BOOL isSlicing;

@property (nonatomic, strong) UIColor *addingColor;

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
    self.addActivityElement = [[AddActivityElement alloc] init];
    self.sliceElement = [[SliceElement alloc] init];
    
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
                [self.addActivityElement hide];
                [self.activityView showCurrentActivity:[[ActivityManager sharedInstance] getCurrentActivity]
                                 chooseActivityElement:self.chooseActivityElement
                                              finished:^{
                    self.state = ACTIVITY_STATE_SHOW_CURRENT;
                }];
            } else if([self shouldStartAddingNewActivityElement:touchLocation]) {
                [self startAddingNewActivityElement:touchLocation];
            } else {
                //start dragging an element
                for(ActivityElement *activityElement in self.activityElements) {
                    if([activityElement isTouching:touchLocation]) {
                        self.selectedActivityElement = activityElement;
                        break;
                    }
                }
                
                //start slicing
                [self startSlicing:touchLocation];
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
            if([self shouldMoveSelectedActivtyElement]) {
                [self moveSelectedActivityElement:touchLocation];
            } else if([self shouldAddNewActivityElement:touchLocation]) {
                [self addNewActivityElement:touchLocation];
            } else if([self shouldUpdateCurrentAddingLocation:touchLocation]) {
                [self updateCurrentAddingLocation:touchLocation];
            } else if ([self shouldUpdateSlicing]) {
                [self updateCurrentSlicingLocation:touchLocation];
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
                    [[ActivityManager sharedInstance] startActivity:activityElement.activity];
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
            } else if([self shouldStopMovingSelectedActivityElement]) {
                [self stopMovingSelectedActivityElement];
            } else if([self shouldCancelAddingNewActivity]) {
                [self cancelAddingActivityElement:touchLocation];
            } else if([self shouldCancelSlicing]) {
                [self cancelSlicing:touchLocation];
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
    [self.addActivityElement show];
    [self.activityView showSettings:self.settingsElement addActivityElement:self.addActivityElement sliceElement:self.sliceElement
                           finished:^{
                               self.state = ACTIVITY_STATE_SETTINGS;
                           }];
}


- (void)slicingTimerFired:(NSTimer *)timer_
{
    [self cancelSlicing:CGPointZero];
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
        [activitiesToReindex addObject:activityElement.activity];
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
    [self calculateAnglesForActivityElements:activityElementsSortedByAngle shouldAnimate:YES
                     ignoringActivityElement:isIgnoringSelected_ ? self.selectedActivityElement : nil];
}


#pragma mark - Settings State Conditions
- (BOOL)shouldStartAddingNewActivityElement:(CGPoint)touchLocation_
{
    return [self.addActivityElement isTouching:touchLocation_] && !self.isEditingActivityElement &&
           !self.isMovingActivityElement;
}


- (BOOL)shouldMoveSelectedActivtyElement
{
    return self.selectedActivityElement != nil && !self.isEditingActivityElement;
}


- (BOOL)shouldAddNewActivityElement:(CGPoint)touchLocation_
{
    return self.isAdding && [self.addActivityElement isTouchingAddLocation:touchLocation_];
}


- (BOOL)shouldUpdateCurrentAddingLocation:(CGPoint)touchLocation_
{
    return self.isAdding && ![self.addActivityElement isTouchingAddLocation:touchLocation_];
}


- (BOOL)shouldStartEditingSelectedActivityElement
{
    return self.selectedActivityElement != nil && !self.isMovingActivityElement;
}


- (BOOL)shouldStopMovingSelectedActivityElement
{
    return self.selectedActivityElement != nil && self.isMovingActivityElement;
}


- (BOOL)shouldCancelAddingNewActivity
{
    return self.isAdding;
}


- (BOOL)shouldUpdateSlicing
{
    return self.isSlicing;
}


- (BOOL)shouldCancelSlicing
{
    return YES;
}


#pragma mark - Settings State Actions
- (void)startAddingNewActivityElement:(CGPoint)touchLocation_
{
    self.isAdding = YES;
    self.addingColor = [[ActivityManager sharedInstance] getAnyColor];
    [self.addActivityElement startAddingWithCurrentLoation:touchLocation_ color:self.addingColor];
}


- (void)moveSelectedActivityElement:(CGPoint)touchLocation_
{
    self.isMovingActivityElement = YES;
    self.activityView.activityElementAtTop = self.selectedActivityElement;
    
    [self moveSelectedActivityToAngle:[Utils angleBetweenPointA:[Utils viewCenter] pointB:touchLocation_]];
    [self calculateActivityElementsIgnoringSelected:YES];
}


- (void)addNewActivityElement:(CGPoint)touchLocation_
{
    self.isAdding = NO;
    
    Activity *activity = [[ActivityManager sharedInstance] createNewActivityWithName:@"New"];
    ActivityElement *activityElement = [[ActivityElement alloc] initWithActivity:activity angle:[Utils angleBetweenPointA:[Utils viewCenter] pointB:touchLocation_]];
    activity.color = self.addingColor;
    
    [self.addActivityElement finishAddingWithAddLocation:activityElement.location activityElementDiameter:80.0 completed:^{
        [activityElement showImmediately];
        self.selectedActivityElement = nil;
        self.isMovingActivityElement = NO;
        self.isEditingActivityElement = NO;
        [self.activityElements addObject:activityElement];
        [self calculateActivityElementsIgnoringSelected:NO];
    }];
}


- (void)updateCurrentAddingLocation:(CGPoint)touchLocation_
{
    [self.addActivityElement setCurrentTouchingLocation:touchLocation_];
}


- (void)startEditingSelectedActivityElement
{
    self.isEditingActivityElement = YES;
    [self.activitySettingsView configureWithActivity:self.selectedActivityElement.activity];
    [self.activitySettingsView show];
}


- (void)stopMovingSelectedActivityElement
{
    self.isMovingActivityElement = NO;
    self.selectedActivityElement = nil;
    [self calculateActivityElementsIgnoringSelected:NO];
}


- (void)cancelAddingActivityElement:(CGPoint)touchLocation_
{
    self.isAdding = NO;
    [self.addActivityElement cancelAddingWithCurrentLocation:touchLocation_];
}


- (void)startSlicing:(CGPoint)touchLocation_
{
    self.isSlicing = YES;
    [self.sliceElement startSlicingWithLocation:touchLocation_];
    
    //We only have certain time to perform slice
    self.slicingTimer = [NSTimer timerWithTimeInterval:SLICE_TIME
                                                target:self
                                              selector:@selector(slicingTimerFired:)
                                              userInfo:nil
                                               repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.slicingTimer forMode:NSDefaultRunLoopMode];
}


- (void)updateCurrentSlicingLocation:(CGPoint)touchLocation_
{
    [self.sliceElement setCurrentTouchLocation:touchLocation_];
    
    ActivityElement *activityElementForRemoval = nil;
    
    for(ActivityElement *activityElement in self.activityElements) {
        if([self.sliceElement hasSlicedThroughActivityElement:activityElement]) {
            [self.slicingTimer invalidate];
            self.isSlicing = NO;
            [self.sliceElement endSlicingWithLocation:touchLocation_];
            activityElementForRemoval = activityElement;
            break;
        }
    }
    
    if(activityElementForRemoval != nil) {
        [self.activityElements removeObject:activityElementForRemoval];
        [[ActivityManager sharedInstance] deleteActivity:activityElementForRemoval.activity];
        self.activityView.activityElementAtTop = nil;
        [self calculateActivityElementsIgnoringSelected:NO];
    }
}


- (void)cancelSlicing:(CGPoint)touchLocation_
{
    if(self.slicingTimer.isValid)
        [self.slicingTimer invalidate];
    
    self.isSlicing = NO;
    [self.sliceElement cancelSlicingWithLocation:touchLocation_];
}


#pragma mark - Event Handlers
- (void)settingViewClosed
{
    self.isEditingActivityElement = NO;
    self.selectedActivityElement = nil;
    
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
            if((ignoredActivityElement_ == nil || ![ignoredActivityElement_ isEqual:activityElement]) &&
               activityElement.newAngle != activityElement.angle)
                [activityElementsToAnimate addObject:activityElement];
        }
        
        [self.activityView moveActivityElementsToNewAngle:activityElementsToAnimate];
    } else {
        [self.activityView redraw];
    }
}

@end
