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


typedef enum {
    ACTIVITY_STATE_ANIMATION,
    ACTIVITY_STATE_SHOW_CURRENT,
    ACTIVITY_STATE_CHOOSE_NEW
} ActivityState;


@interface ActivityVC ()

@property (nonatomic, assign) ActivityState state;
@property (nonatomic, weak) IBOutlet ActivityView *activityView;
@property (nonatomic, strong) NSArray *activityElements;

@property (nonatomic, assign) CGPoint chooseNewActivityCircleCenter;
@property (nonatomic, assign) CGFloat chooseNewActivityCircleDiameter;

@end


@implementation ActivityVC


#pragma mark - Initialization
- (id)init
{
    if((self = [super initWithNibName:@"ActivityView" bundle:nil]) == nil)
        return nil;
    
    //[[ActivityManager sharedInstance] createNewActivityWithName:@"Dźwiedź"];

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.chooseNewActivityCircleCenter = CGPointMake(self.view.frame.size.width/2.0,
                                                     self.view.frame.size.height/2.0);
    self.chooseNewActivityCircleDiameter = 80.0;
    
    Activity *currentActivity = [[ActivityManager sharedInstance] currentActivity];
    self.activityElements = [self setupActivityElements];
    self.activityView.chooseNewActivityCircleCenter = self.chooseNewActivityCircleCenter;
    self.activityView.chooseNewActivityCircleDiameter = self.chooseNewActivityCircleDiameter;
    
    self.state = ACTIVITY_STATE_ANIMATION;
    [self.activityView showCurrentActivity:currentActivity finished:^{
        self.state = ACTIVITY_STATE_SHOW_CURRENT;
    }];
}


- (NSArray *)setupActivityElements
{
    NSMutableArray *activityElements = [NSMutableArray array];
    NSArray *activities = [[ActivityManager sharedInstance] activities];
    
    CGFloat startAngle;
    CGFloat angleDistance;
    
    if((activities.count-1) * INITIAL_DISTANCE_DEGREES <= 360.0) {
        angleDistance = INITIAL_DISTANCE_DEGREES;
        if(activities.count%2 == 0)
            startAngle = -((activities.count - 2)*INITIAL_DISTANCE_DEGREES)/2.0 - 0.5*INITIAL_DISTANCE_DEGREES;
        else
            startAngle = -((activities.count - 1)*INITIAL_DISTANCE_DEGREES)/2.0;
    } else {
        startAngle = -180.0;
        angleDistance = 360.0/activities.count;
    }
    
    Activity *currentActivity = [[ActivityManager sharedInstance] currentActivity];
    
    for(int i=0; i<activities.count; i++) {
        if([currentActivity.name isEqualToString:((Activity *)activities[i]).name])
            continue;
        
        CGFloat angle = startAngle+i*angleDistance;
        ActivityElement *activityElement = [[ActivityElement alloc] initWithActivity:activities[i] angle:angle];
        [activityElements addObject:activityElement];
    }
    
    
    return [activityElements copy];
}


#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
    UITouch *touch = [touches_ anyObject];
    
    switch(self.state) {
        case ACTIVITY_STATE_SHOW_CURRENT:
        {
            if([self isTouchingNewActivityCircle:touch]) {
                self.state = ACTIVITY_STATE_ANIMATION;
                [self.activityView showActivityElements:self.activityElements finished:^{
                    self.state = ACTIVITY_STATE_CHOOSE_NEW;
                }];
            }
        }
            break;
        case ACTIVITY_STATE_CHOOSE_NEW:
            break;
        default:
            break;
    }
}


- (void)touchesMoved:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
}


- (void)touchesEnded:(NSSet *)touches_ withEvent:(UIEvent *)event_
{
    CGPoint touchLocation = [[touches_ anyObject] locationInView:self.view];

    switch(self.state) {
        case ACTIVITY_STATE_SHOW_CURRENT:
            break;
        case ACTIVITY_STATE_CHOOSE_NEW:
        {
            self.state = ACTIVITY_STATE_ANIMATION;
            
            for(ActivityElement *activityElement in self.activityElements) {
                if([activityElement isTouching:touchLocation]) {
                    [[ActivityManager sharedInstance] startActivity:[activityElement associatedActivity]];
                    break;
                }
            }

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
                
                
#pragma mark - Utils
- (BOOL)isTouchingNewActivityCircle:(UITouch *)touch_
{
    CGFloat distance = [Utils distanceBetweenPointA:[touch_ locationInView:self.view] pointB:self.chooseNewActivityCircleCenter];
    if(distance <= self.chooseNewActivityCircleDiameter/2.0)
        return YES;
    
    return NO;
}

@end
