//
//  ActivitySettingsView.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 03.09.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ActivitySettingsView.h"

#import "Activity.h"

#import "ActivityManager.h"

#import "Utils.h"


#define BLUR_TARGET_ALPHA 0.95


@interface ActivitySettingsView ()

@property (nonatomic, weak) IBOutlet UITextField *activityNameField;
@property (nonatomic, weak) IBOutlet UICollectionView *activityImagesCollection;

@property (nonatomic, strong) Activity *activity;

//Events
@property (nonatomic, strong) NSMutableArray *onHideEventHandlers;

@property (nonatomic, assign) CGRect desiredSize;
@property (nonatomic, strong) UIToolbar *toolbar;

@end


@implementation ActivitySettingsView

#pragma mark - Initialization
- (id)init
{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"ActivitySettingsView" owner:nil options:nil];
    ActivitySettingsView *view = nibObjects[0];
    
    return view;
}


- (id)initWithFrame:(CGRect)frame_
{
    if((self = [super initWithFrame:frame_]) == nil)
        return nil;
    
    [self setup];
    
    return self;
}


- (id)initWithCoder:(NSCoder *)coder_
{
    if((self = [super initWithCoder:coder_]) == nil)
        return nil;
    
    [self setup];
    
    return self;
}


- (void)setup
{
    self.userInteractionEnabled = NO;
    self.layer.opacity = 0.0;

    CGRect desiredSize = self.frame;
    desiredSize.origin = CGPointMake(self.desiredSize.origin.x, [Utils viewSize].height);
    self.desiredSize = desiredSize;

    self.onHideEventHandlers = [NSMutableArray array];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = self.desiredSize;
}


- (void)configureWithActivity:(Activity *)activity_
{
    self.activity = activity_;
    self.activityNameField.text = self.activity.name;
}


#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField_
{
    [self doneButtonAction:nil];
    
    return YES;
}


#pragma mark - Events
- (void)addOnHideEventHandler:(void (^)())eventHandlerBlock_
{
    [self.onHideEventHandlers addObject:eventHandlerBlock_];
}


#pragma mark - Actions
- (IBAction)cancelButtonAction:(id)sender_
{
    [self.activityNameField resignFirstResponder];
    [self hide];
}


- (IBAction)doneButtonAction:(id)sender_
{
    //check if it hasn't been changed
    if([self.activity.name isEqualToString:self.activityNameField.text]) {
        
    //Check if desired name is already in use
    }else if([[ActivityManager sharedInstance] getActivityWithName:self.activityNameField.text] != nil) {
        return;
    } else {
        self.activity.name = self.activityNameField.text;
    }
    
    [self hide];
}


#pragma mark - Control
- (void)show
{
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.layer.opacity = BLUR_TARGET_ALPHA;
                         
                         CGRect frame = self.frame;
                         frame.origin = CGPointMake(self.frame.origin.x, 0.0);
                         self.frame = frame;
                     } completion:^(BOOL finished) {
                         self.userInteractionEnabled = YES;
                         [self.activityNameField becomeFirstResponder];
                     }];
}


- (void)hide
{
    [Utils executeBlocksInArray:self.onHideEventHandlers];
    
    self.userInteractionEnabled = NO;
    [self.activityNameField resignFirstResponder];
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.layer.opacity = 0.0;
         
                         CGRect frame = self.frame;
                         frame.origin = CGPointMake(self.frame.origin.x, [Utils viewSize].height);
                         self.frame = frame;
                     } completion:^(BOOL finished) {
                     }];
}

@end
