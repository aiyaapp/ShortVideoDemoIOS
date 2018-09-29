//
//  AppDelegate.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "InputViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    InputViewController *inputVC = [[InputViewController alloc]init];
    UINavigationController *rootVC = [[UINavigationController alloc]initWithRootViewController:inputVC];
    rootVC.navigationBar.hidden = YES;
    
    self.window.rootViewController = rootVC;
    
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)effectTypeWithTime:(CGFloat)time{
    // 找到离当前播放位置最近的特效
    if (!self.totalTimeModel) {
        self.totalTimeModel = [NSMutableArray array];
    }
    
    NSArray *effectIndexResult = [self.totalTimeModel lastObject].effectIndexResult;
    
    EffectIndexModel *lastModel;
    for (EffectIndexModel *indexModel in effectIndexResult) {
        if (!lastModel) {
            lastModel = indexModel;
        }else {
            if (lastModel.startTime <= indexModel.startTime && indexModel.startTime <= time) {
                lastModel = indexModel;
            }
        }
    }
    
    if (!lastModel) {
        return NSUIntegerMax;
    }
    
    // 返回特效
    return lastModel.identification;
}

@end
