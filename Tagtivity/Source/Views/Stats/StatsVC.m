//
//  StatsVC.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 23.10.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "StatsVC.h"

#import "StatsListVC.h"
#import "Utils.h"


@interface StatsVC ()

@property (nonatomic, strong) StatsListVC *statsListVC;
@property (nonatomic, strong) UIToolbar *backgroundView;

@end


@implementation StatsVC

#pragma mark - Initialization
- (id)init
{
    self.statsListVC = [[StatsListVC alloc] init];
    
    self = [super initWithRootViewController:self.statsListVC];
    if(self == nil)
        return nil;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add pretty glass
    self.backgroundView = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    //[self.view insertSubview:self.backgroundView atIndex:0];
    self.backgroundView.layer.opacity = 0.95;
    [self.view.layer insertSublayer:self.backgroundView.layer atIndex:0];
    
    //move whole view out of view ;)
    CGRect viewRect = self.view.frame;
    viewRect.origin = CGPointMake([Utils viewSize].width, 0.0);
    self.view.frame = viewRect;
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwpieAction:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeRecognizer];
}


#pragma mark - Gesture Recognizer Delegate
- (IBAction)rightSwpieAction:(id)sender_
{
    [self hide];
}


#pragma mark - Table View Delegate


#pragma mark - Control
- (void)show
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.2];
    {
        CGRect viewRect = self.view.frame;
        viewRect.origin = CGPointMake(0.0, 0.0);
        self.view.frame = viewRect;
    }
    [UIView commitAnimations];
}


- (void)hide
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.2];
    {
        CGRect viewRect = self.view.frame;
        viewRect.origin = CGPointMake([Utils viewSize].width, 0.0);
        self.view.frame = viewRect;
    }
    [UIView commitAnimations];
}


@end
