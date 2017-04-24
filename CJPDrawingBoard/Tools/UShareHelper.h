//
//  UShareHelper.h
//  02-圆形裁剪
//
//  Created by lucky－ios on 2017/4/19.
//  Copyright © 2017年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMSocialWechatHandler.h"
#import <UShareUI/UMSocialUIManager.h>
#import "UMSocialWechatHandler.h"

#define USHARE_APPKEY @"58f6f00d45297d22eb0009c2"
#define WX_APPKEY @"wx3f87b973ebfec98a"
#define WX_APPSCRET @"6e7fc097070f4b6c0ef5951c091a73e4"

@interface UShareHelper : NSObject

+ (void)shareWithUI:(UIImage *)img controller:(UIViewController *)controller;

+ (void)loadUShare;
@end
