//
//  AppDelegate.m
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 04/05/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "DMGesturedNavigationController.h"
#import "WithinNavigationViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    ViewController *controller1 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller1.view setBackgroundColor:[UIColor blueColor]];
    controller1.title = @"First";
    ViewController *controller2 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller2.view setBackgroundColor:[UIColor redColor]];
    controller2.title = @"Second";
    ViewController *controller3 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller3.view setBackgroundColor:[UIColor greenColor]];
    controller3.title = @"Third";
    ViewController *controller4 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller4.view setBackgroundColor:[UIColor orangeColor]];
    controller4.title = @"Fourfth";
        DMGesturedNavigationController *container = [[DMGesturedNavigationController alloc]initWithViewControllers:@[controller1, controller2, controller3, controller4]];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:container];
    self.window.rootViewController = navigation;
    [container.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [container setAnimatedNavbarChange:YES];
    [navigation setNavigationBarHidden:YES animated:NO];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
