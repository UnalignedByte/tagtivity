//
//  ActivityElement.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 24.05.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ActivityElement.h"

#import <CoreText/CoreText.h>
#import "Activity.h"
#import "Utils.h"


#define CIRCLE_DIAMETER 80.0
static CGFloat textDiameter = 70.0;
static CGFloat fontSize = 16.0;


@interface ActivityElement () {
    Activity *_activity;
    CGPoint _location;
    CGFloat _diameter;
}

@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) CGPoint drawLocation;
@property (nonatomic, assign) CGFloat drawDistance;
@property (nonatomic, assign) CGFloat drawDiameter;
@property (nonatomic, assign) CGFloat drawAlpha;
@property (nonatomic, assign) CGFloat drawTextDiameter;
@property (nonatomic, assign) CGFloat drawFontSize;

@end


@implementation ActivityElement

@synthesize activity=_activity;
@synthesize location=_location;
@synthesize diameter=_diameter;

#pragma mark - Initialization
- (id)initWithActivity:(Activity *)activity_ angle:(CGFloat)angle_;
{
    if((self = [super init]) == nil)
        return nil;
    
    _activity = activity_;
    _diameter = CIRCLE_DIAMETER;
    self.angle = angle_;
    self.isVisible = NO;
    
    return self;
}


#pragma mark - Properties
- (void)setAngle:(CGFloat)angle_
{
    _angle = angle_;
    CGFloat distance = ([Utils viewSize].width - _diameter)/2.0;
    _location = [self getLocationFromAngle:_angle distance:distance];
    self.drawLocation = [self getLocationFromAngle:_angle distance:self.drawDistance];
}


#pragma mark - Drawing
- (void)drawInContext:(CGContextRef)ctx_
{
    if(!self.isVisible)
        return;

    const CGFloat *colorComponents = CGColorGetComponents([(UIColor *)self.activity.color CGColor]);
    UIColor *color = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:self.drawAlpha];
    
    CGContextSetFillColorWithColor(ctx_, color.CGColor);
    
    //Draw circle
    CGRect circleRect = CGRectMake(self.drawLocation.x - self.drawDiameter/2.0, self.drawLocation.y - self.drawDiameter/2.0,
                                   self.drawDiameter, self.drawDiameter);
    CGContextFillEllipseInRect(ctx_, circleRect);

    //Draw Name
    [self drawCircuralTextInContext:ctx_ text:self.activity.name
                           fontSize:self.drawFontSize
                             center:CGPointMake(self.drawLocation.x, self.drawLocation.y)
                           diameter:self.drawDiameter*0.6];
}


- (void)drawCircuralTextInContext:(CGContextRef)ctx_ text:(NSString *)text_
                       fontSize:(CGFloat)fontSize_
                         center:(CGPoint)center_
                       diameter:(CGFloat)diameter_
{
    CGContextSaveGState(ctx_);
    CGContextTranslateCTM(ctx_, 0.0, [Utils viewSize].height);
    CGContextScaleCTM(ctx_, 1.0, -1.0);
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize_]};
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text_ attributes:attributes];
    CTLineRef textLine = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedText);
    CGRect textRect = CTLineGetImageBounds(textLine, ctx_);
    
    CGFloat textTotalAngle = ((textRect.size.width)/(M_PI*diameter_))*360.0;
    CGFloat textStartAngle = -textTotalAngle*0.5;
    
    //draw each character at given angle
    for(NSInteger i=0; i<text_.length; i++) {
        //generate string so far
        NSString *textSoFar = [text_ substringToIndex:i+1];
        NSAttributedString *attributedTextSoFar = [[NSAttributedString alloc] initWithString:textSoFar attributes:attributes];
        CTLineRef textLineSoFar = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedTextSoFar);
        //generate letter
        NSString *letter = [text_ substringWithRange:NSMakeRange(i, 1)];
        NSAttributedString *attributedLetter = [[NSAttributedString alloc] initWithString:letter attributes:attributes];
        CTLineRef letterLine = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedLetter);
        //calculate letter's angle
        CGRect textRectSoFar = CTLineGetImageBounds(textLineSoFar, ctx_);
        CGRect letterRect = CTLineGetImageBounds(letterLine, ctx_);
        CGFloat letterAngle = textStartAngle + ((textRectSoFar.size.width-letterRect.size.width*0.5)/textRect.size.width)*textTotalAngle;
        
        CGContextSaveGState(ctx_);

        //position & rotate letter
        CGContextSetTextPosition(ctx_, -letterRect.size.width*0.5, 0.0);
        CGFloat x = center_.x + sin(RAD(letterAngle))*diameter_*0.5;
        CGFloat y = center_.y - cos(RAD(letterAngle))*diameter_*0.5;
        CGContextTranslateCTM(ctx_, x, [Utils viewSize].height - y);
        CGContextRotateCTM(ctx_, RAD(-letterAngle));
        //draw letter
        CTLineDraw(letterLine, ctx_);
        
        CGContextRestoreGState(ctx_);
    }
    
    CGContextRestoreGState(ctx_);
}


#pragma mark - Utils
- (CGPoint)getLocationFromAngle:(CGFloat)angle_ distance:(CGFloat)distance_
{
    CGFloat xPos = [Utils viewSize].width/2.0 + sin(RAD(angle_))*distance_;
    CGFloat yPos = [Utils viewSize].height/2.0 - cos(RAD(angle_))*distance_;
    
    return CGPointMake(xPos, yPos);
}


#pragma mark - Control
- (void)show
{
    if(self.isVisible)
        return;
    
    self.isVisible = YES;
    [Utils animateValueFrom:0.0 to:1.0 duration:0.6 curve:AnimationCurveElasticOut block:^(double value) {
        self.drawDiameter = _diameter*value;
        self.drawAlpha = value;
        self.drawDistance = (([Utils viewSize].width - self.drawDiameter)/2.0)*value;
        self.drawLocation = [self getLocationFromAngle:_angle distance:self.drawDistance];
        
        self.drawTextDiameter = textDiameter*value;
        self.drawFontSize = fontSize*value;
    }];
}


- (void)showImmediately
{
    self.isVisible = YES;
    
    self.drawDiameter = _diameter;
    self.drawAlpha = 1.0;
    self.drawDistance = (([Utils viewSize].width - self.drawDiameter)/2.0);
    self.drawLocation = _location;
}


- (void)hide
{
    if(!self.isVisible)
        return;
    
    [Utils animateValueFrom:1.0 to:0.0 duration:0.8 curve:AnimationCurveElasticIn block:^(double value) {
        self.drawDiameter = _diameter*value;
        self.drawAlpha = value;
        self.drawDistance = (([Utils viewSize].width - self.drawDiameter)/2.0)*value;
        self.drawLocation = [self getLocationFromAngle:_angle distance:self.drawDistance];
        if(value <= 0.0)
            self.isVisible = NO;
    }];
}


#pragma mark - Information
- (BOOL)isEqual:(id)object_
{
    if([object_ class] != [ActivityElement class])
        return NO;
    
    ActivityElement *activityElement = object_;
    
    if([activityElement.activity.name isEqualToString:self.activity.name])
        return YES;
    
    return NO;
}


- (NSComparisonResult)compareByIndex:(ActivityElement *)otherElement_
{
    return [self.activity.index compare:otherElement_.activity.index];
}


- (NSComparisonResult)compareByAngle:(ActivityElement *)otherElement_
{
    if(self.angle < otherElement_.angle)
        return NSOrderedAscending;
    
    if(self.angle > otherElement_.angle)
        return NSOrderedDescending;
    
    return NSOrderedSame;
}


- (BOOL)isTouching:(CGPoint)touchLocation_
{
    CGFloat distance = [Utils distanceBetweenPointA:touchLocation_ pointB:_location];
    if(distance <= _diameter/2.0)
        return YES;
    
    return NO;
}

@end
