//
//  ColorCell.m
//  Tagtivity
//
//  Created by Rafał Grodziński on 08.10.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import "ColorCell.h"


@interface ColorCell ()

@property (nonatomic, weak) IBOutlet UIView *colorView;
@property (nonatomic, weak) IBOutlet UIImageView *selectedImageView;

@end


@implementation ColorCell

#pragma mark - Initialization
- (void)configureWithColor:(UIColor *)color_ isSelected:(BOOL)isSelected_
{
    self.colorView.backgroundColor = color_;
    self.selectedImageView.hidden = !isSelected_;
}


#pragma mark - Info
+ (CGSize)size
{
    static ColorCell *cell;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"ColorCell" owner:nil options:nil];
        cell = nibObjects[0];
    });
    
    return cell.frame.size;
}

@end
