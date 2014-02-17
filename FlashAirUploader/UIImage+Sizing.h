//
//  UIImage+Sizing.h
//  FlashAirUploader
//
//  Created by k2o on 2014/02/17.
//  Copyright (c) 2014年 imk2o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Sizing)

- (UIImage*)resizedImageWithSize:(CGSize)size;
- (UIImage*)resizedImageWithMinSize:(CGFloat)minSize;
- (UIImage*)resizedImageWithMaxSize:(CGFloat)maxSize;

@end
