//
//  UIImage+Image.h
//  02-圆形裁剪
//
//  Created by teacher on 15-1-22.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Image)


/**
 *  圆形裁剪图片
 *
 *  @param borderW   圆环宽度
 *  @param color     圆环颜色
 *  @param imageName 图片名称
 *
 *  @return 裁剪好的圆形图片
 */
+ (UIImage *)imageWithCircleBorderW:(CGFloat)borderW color:(UIColor *)color imageName:(NSString *)imageName;

@end
