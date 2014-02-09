//
//  ActivityView.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 18.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Activity;
@class ActivityElement;
@class ChooseActivityElement;
@class SettingsElement;
@class AddActivityElement;
@class SliceElement;


@interface ActivityView : UIView

@property (nonatomic, assign) CGPoint chooseNewActivityCircleCenter;
@property (nonatomic, assign) CGFloat chooseNewActivityCircleDiameter;
@property (nonatomic, strong) ActivityElement *activityElementAtTop;


//Control
- (void)redraw;
- (void)showCurrentActivity:(Activity *)activity_ chooseActivityElement:(ChooseActivityElement *)chooseActivityElement_
                   finished:(void (^)())block_;
- (void)showActivityElements:(NSArray *)activityElements_ finished:(void (^)())block_;
- (void)showSettings:(SettingsElement *)settingsElement_ activityElements:(NSMutableArray *)activityElements_ addActivityElement:(AddActivityElement *)addActivityElement_
        sliceElement:(SliceElement *)sliceElement_ finished:(void (^)())block_;
- (void)moveActivityElementsToNewAngle:(NSArray *)activityElements_;

@end
