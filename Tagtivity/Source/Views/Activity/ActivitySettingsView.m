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


@interface ActivitySettingsView ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UITextField *activityNameField;
@property (nonatomic, weak) IBOutlet UICollectionView *activityImagesCollection;

@property (nonatomic, strong) Activity *activity;

//Events
@property (nonatomic, strong) NSMutableArray *onHideEventHandlers;

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
    self.alpha = 0.0;

    self.onHideEventHandlers = [NSMutableArray array];
}


- (void)configureWithActivity:(Activity *)activity_
{
    self.activity = activity_;
    self.activityNameField.text = self.activity.name;
}


#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField_
{
    //Check if desired name is already in use
    if([[ActivityManager sharedInstance] getActivityWithName:textField_.text] != nil) {
        self.activityNameField.text = self.activity.name;
        return NO;
    }
    
    self.activity.name = self.activityNameField.text;
    [self.activityNameField resignFirstResponder];
    
    return YES;
}


#pragma mark - Actions
- (IBAction)cancelButtonAction:(id)sender_
{
    [self.activityNameField resignFirstResponder];
    [self hide];
}


#pragma mark - Control
- (void)show
{
    CGRect viewFrame = self.frame;
    viewFrame.size = [Utils viewSize];
    self.frame = viewFrame;
    
    CGRect containerViewFrame = self.containerView.frame;
    CGFloat containerViewX = (self.frame.size.width - self.containerView.frame.size.width)/2.0;
    CGFloat containerViewY = (self.frame.size.height - self.containerView.frame.size.height)/2.0;
    containerViewFrame.size = CGSizeMake(containerViewX, containerViewY);

    self.userInteractionEnabled = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
        self.alpha = 1.0;
    [UIView commitAnimations];
}


- (void)hide
{
    [Utils executeBlocksInArray:self.onHideEventHandlers];
    
    self.userInteractionEnabled = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
        self.alpha = 0.0;
    [UIView commitAnimations];
}


#pragma mark - Events
- (void)addOnHideEventHandler:(void (^)())eventHandlerBlock_
{
    [self.onHideEventHandlers addObject:eventHandlerBlock_];
}

@end
