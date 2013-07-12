//
//  ActivityView.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 18.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Activity;
@class ChooseActivityElement;
@class SettingsElement;
@class AddNewActivityElement;


@interface ActivityView : UIView

@property (nonatomic, assign) CGPoint chooseNewActivityCircleCenter;
@property (nonatomic, assign) CGFloat chooseNewActivityCircleDiameter;

//Control
- (void)showCurrentActivity:(Activity *)activity_ chooseActivityElement:(ChooseActivityElement *)chooseActivityElement_
                   finished:(void (^)())block_;
- (void)showActivityElements:(NSArray *)activityElements_ finished:(void (^)())block_;
- (void)showSettings:(SettingsElement *)settingsElement_ addNewActivityElement:(AddNewActivityElement *)addNewActivityElement_
            finished:(void (^)())block_;

@end
