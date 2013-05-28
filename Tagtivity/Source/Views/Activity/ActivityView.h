//
//  ActivityView.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 18.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Activity;


@interface ActivityView : UIView

//Control
- (void)showCurrentActivity:(Activity *)activity_ finished:(void (^)())block_;
- (void)hideCurrentActivity:(void (^)())block_;
- (void)showActivityElements:(NSArray *)activityElements_ finished:(void (^)())block_;
- (void)hideActivityElements:(void (^)())block_;

@end
