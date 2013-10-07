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

    self.desiredSize = self.frame;

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
    [self.activityNameField resignFirstResponder];
    
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
    //Check if desired name is already in use
    if([[ActivityManager sharedInstance] getActivityWithName:self.activityNameField.text] != nil) {
        return;
    }
    
    self.activity.name = self.activityNameField.text;
    [self hide];
}


#pragma mark - Control
- (void)show
{
    CGRect viewFrame = self.frame;
    viewFrame.size = [Utils viewSize];
    self.frame = viewFrame;

    self.userInteractionEnabled = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
        self.layer.opacity = BLUR_TARGET_ALPHA;
    [UIView commitAnimations];
}


- (void)hide
{
    [Utils executeBlocksInArray:self.onHideEventHandlers];
    
    self.userInteractionEnabled = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
        self.layer.opacity = 0.0;
    [UIView commitAnimations];
}

@end
