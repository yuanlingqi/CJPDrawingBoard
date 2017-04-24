//
//  UIImage+Image.m
//  02-圆形裁剪
//
//  Created by teacher on 15-1-22.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "UIImage+Image.h"

@implementation UIImage (Image)
+ (UIImage *)imageWithCircleBorderW:(CGFloat)borderW color:(UIColor *)color imageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    // 设置大圆的rect
    CGFloat w = image.size.width + 2 * borderW;
    CGFloat h = image.size.height + 2 * borderW;
    CGRect bigCirCleRect = CGRectMake(0, 0, w, h);
    
    // 1.开启上下文
    UIGraphicsBeginImageContextWithOptions(bigCirCleRect.size, NO, 0);
    
    // 2.拼接路径
    
    // 2.1 绘制大圆
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bigCirCleRect];
    
    // 设置圆环颜色
    [color set];
    
    [path fill];
    
    // 设置裁剪区域:默认只会影响后面画的东西,会把超出裁剪区域的内容裁剪掉
    CGRect clipRect = CGRectMake(borderW, borderW, image.size.width, image.size.height);
    // 描述裁剪区域路径
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:clipRect];
    [clipPath addClip];
    
    // 绘制图片
    [image drawAtPoint:CGPointMake(borderW, borderW)];
    
    // 获取图片
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return image;
}
@end
