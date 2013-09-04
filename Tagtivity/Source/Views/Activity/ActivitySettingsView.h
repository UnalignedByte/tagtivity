//
//  ActivitySettingsView.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 03.09.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Activity;


@interface ActivitySettingsView : UIView <UITextFieldDelegate>

//Initialization
- (id)init;
- (void)configureWithActivity:(Activity *)activity_;

//Control
- (void)show;
- (void)hide;

//Events
- (void)addOnHideEventHandler:(void (^)())eventHandlerBlock_;

@end
