//
//  ColorCell.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 08.10.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString *kColorCellIdentifier = @"ColorCellIdentifier";


@interface ColorCell : UICollectionViewCell

//Initialization
- (void)configureWithColor:(UIColor *)color_ isSelected:(BOOL)isSelected_;

//Info
+ (CGSize)size;

@end
