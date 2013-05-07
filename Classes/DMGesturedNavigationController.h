//
//  DMGesturedNavigationController.h
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 04/05/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMGesturedChildViewController <NSObject>
@optional
- (void)didBecomeActive;
- (void)didResignActive;
@end

@interface DMGesturedNavigationController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, readonly, strong) UIViewController *topViewController;
@property (nonatomic, readonly, strong) UIViewController *visibleViewController;
@property (nonatomic, readonly, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UIBarButtonItem *customBackButtonItem;
@property (nonatomic, getter = isPreserveStack) BOOL preserveStack;
@property (nonatomic, getter = isNavigatioNBarHidden) BOOL navigationBarHidden;
@property (nonatomic, getter = isAllowSideBouncing) BOOL allowSideBoucing;
@property (nonatomic, getter = isAllowSwipeTransition) BOOL allowSwipeTransition;
@property (nonatomic, getter = isAnimatedNavbarChange) BOOL animatedNavbarChange;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popViewConrollerAnimated:(BOOL)animated;
- (void)popToRootViewControllerAnimated:(BOOL)animated;
- (void)navigateToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;

@end

@interface UIViewController (UIViewControllerGesturedNavigationController)
@property (nonatomic, readonly, strong) DMGesturedNavigationController *gesturedNavigationController;
@property (nonatomic, readonly, strong) UIViewController *previousViewController;
@property (nonatomic, readonly, strong) UIViewController *nextViewController;
- (void)setActive;
@end
