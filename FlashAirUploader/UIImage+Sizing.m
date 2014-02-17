//
//  UIImage+Sizing.m
//  FlashAirUploader
//
//  Created by k2o on 2014/02/17.
//  Copyright (c) 2014年 imk2o. All rights reserved.
//

#import "UIImage+Sizing.h"

@implementation UIImage (Sizing)

- (UIImage*)resizedImageWithSize:(CGSize)size
{
    //UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (UIImage*)resizedImageWithMinSize:(CGFloat)minSize
{
    if (self.size.width > self.size.height) {
        CGFloat width = (self.size.width / self.size.height) * minSize;
        return [self resizedImageWithSize:CGSizeMake(width, minSize)];
    } else {
        CGFloat height = (self.size.height / self.size.width) * minSize;
        return [self resizedImageWithSize:CGSizeMake(minSize, height)];
    }
}

- (UIImage*)resizedImageWithMaxSize:(CGFloat)maxSize
{
    if (self.size.width > self.size.height) {
        CGFloat width = (self.size.height / self.size.width) * maxSize;
        return [self resizedImageWithSize:CGSizeMake(width, maxSize)];
    } else {
        CGFloat height = (self.size.width / self.size.height) * maxSize;
        return [self resizedImageWithSize:CGSizeMake(maxSize, height)];
    }
}

@end
