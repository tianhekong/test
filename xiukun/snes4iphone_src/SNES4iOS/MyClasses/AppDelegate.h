//
//  AppDelegate.h
//  TestDemo
//
//  Created by lfh on 13-4-1.
//  Copyright (c) 2013年 linfh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegateEx : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
