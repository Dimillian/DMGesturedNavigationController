//
//  DMGesturedNavigationController.h
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 04/05/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMGesturedNavigationController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, readonly, strong) UIViewController *visibleViewController;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
