//
//  DMGesturedNavigationController.h
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 04/05/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Type of stack available
 DMGesturedNavigationControllerStackNavigationFree The user can freely go back and forth in the stack, 
 child view controller will never be removed from the stack, only when you push a new one with the flag
 DMGesturedNavigationControllerStackLikeNavigationController The stack will work like a standard
 UINavigationController, once the user go back in the stack, the last child view controller displayed
 will be removed from the hierarchy (and released)
 */
typedef NS_ENUM(NSInteger, DMGesturedNavigationControllerStackType) {
    DMGesturedNavigationControllerStackNavigationFree,
    DMGesturedNavigationControllerStackLikeNavigationController
};

/**
 Animation to use when you pop or delete a UIViewController 
 By default it use the a new custom animation, but you can set it to the classic one
 */
typedef NS_ENUM(NSInteger, DMGesturedNavigationControllerPopRemoveAnimation){
    DMGesturedNavigationControllerPopAnimationClassic,
    DMGesturedNavigationControllerPopAnimationNewWay
};

/**
 DMGesturedChildViewControllerNotifications, you can implement this protocol in your UIViewController subclass
 which are used in a DMGesturedNavigationController. If implemented those methods will be called by 
 DMGesturedNavigationController to notify your UIViewController about it's current state
 Do not to call super.
 You should use these methods instead of viewDidAppear and viewWillAppear. DMGesturedViewController does not
 guarantee to call them only once. Those method will only be called at the right time.
 */
@protocol DMGesturedChildViewControllerNotifications <NSObject>
@optional
/** 
 Called when your view controller did show. Only called once until it hide.
 */
- (void)childViewControllerdidShow;
/**
 Called when your view controller did hide. Only called once until it hide.
 */
- (void)childViewControllerdidHide;
/**
 Called when your view controller become active. An active state is when the user effectively ended the 
 swipe transition gesture and transition animations are done.
 */
- (void)childViewControllerdidBecomeActive;
/**
 Called when your view controller become inactive. An inactive your when the view controller is not visible anymore and that gesture and transition animations are ended.
 */
- (void)childViewControllerdidResignActive;
/** 
 Called when your view controller could become the next active one. When the user scrolled more than 50% of it
 Don't assume that it will the active one.
 */
- (void)childViewControllerCouldBecomeActive;
/**
 Called when your view controller could become the inactive. When the user scrolled more than 50% out of it
 Don't assume that it will the next inactive one.
 */
- (void)childViewControllerCouldBecomeInactive;
/**
 Called when a view controller move. Provide you the actual visible width float value wrapped in an NSNumber
 It is not called if the view controller is not visible
 For example, on an iPhone, if your view controller is full screen, this values can vary from 0.0 to 320.0.
 */
- (void)childViewControllerVisiblePartDidChange:(NSNumber *)visiblePartWidth;

/**
 If you implement this you have a chance to set the title of your root view controller only once
 you parent DMGesturedNavigationController is ready.
*/
- (void)childViewControllerCouldProvideTitle;
@end

@interface DMGesturedNavigationController : UIViewController <UIScrollViewDelegate>

/**
 Child view controllers can be swapped at any time by setting this property to a new value.
 The view controllers currently on the navigation stack.
 The root view controller is at index 0 in the array, the back view controller is at index n-2, and the top controller is at index n-1, where n is the number of items in the array.
 */
@property (nonatomic, strong) NSArray *viewControllers;
/**
 The view controller at the top of the navigation stack
  */
@property (nonatomic, readonly, strong) UIViewController *topViewController;
/**
 The view controller associated with the currently visible view in the navigation interface
 */
@property (nonatomic, readonly, strong) UIViewController *visibleViewController;
/**
 The navigation bar managed by the gestured navigation controller.
 */
@property (nonatomic, readonly, strong) UINavigationBar *navigationBar;
/**
 If you set this property to a UIBarButtonItem it will be used as a back button, the action and target
 will be set internally you can leave them to nil
 You can also implement a UILeftBarButtonItem in your UIViewController navigation item, in this case
 no back bar button item will be provided. 
 */
@property (nonatomic, strong) UIBarButtonItem *customBackButtonItem;
/**
 The stack type, refer to DMGesturedNavigationControllerStackType enum for detail
 */
@property (nonatomic) DMGesturedNavigationControllerStackType stackType;
/**
 The pop animation, refer to DMGesturedNavigationControllerPopRemoveAnimation enum for detail
 */
@property (nonatomic) DMGesturedNavigationControllerPopRemoveAnimation popAnimationType;
/**
 A Boolean value that determines whether the navigation bar is hidden.
 If YES, the navigation bar is hidden. 
 The default value is NO. Setting this property does not animate the hiding or showing of the navigation bar; 
 use setNavigationBarHidden:animated: for that purpose.
 */
@property (nonatomic, getter = isNavigatioNBarHidden) BOOL navigationBarHidden;
/**
 Set to NO if you don't want the user to be able to do a bounce gesture.
 Default value is YES.
 */
@property (nonatomic, getter = isAllowSideBouncing) BOOL allowSideBoucing;
/*
 Set to NO if you want to disable the primary feature of this class and be left with a buggy
 UINavigationController implementation :) .
 Default value is YES.
 */
@property (nonatomic, getter = isAllowSwipeTransition) BOOL allowSwipeTransition;
/*
 Set to NO if you don't want to animate the UINavigationItem pop and push of the navigation bar.
 You might set it to NO before doing intensive modification of the stack which could lead to a break
 of the UINavigationBar stack. DMGesturedNavigationController will always try to rebuild it if corrupted.
 Default value is YES.
 */
@property (nonatomic, getter = isAnimatedNavbarChange) BOOL animatedNavbarChange;

/*
 Set to NO if you don't want shadow for the first and the last view controller when the user can scroll the view
 over the edge
 Default value is YES.
 */
@property (nonatomic, getter = isDisplayEdgeShadow) BOOL displayEdgeShadow;

/*
 Set the background color of DMGesturedNavigationController
 You can see the background color when you scroll over the dge
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/*
 Scale animation when a view controller is swiped
 Default value is NO
 */
@property  (nonatomic, getter = isScalingWhenSwipe) BOOL scalingWhenSwipe;

/*
 if scalingWhenSwipe is set to YES then you can set the minimum scale
 Default value is 0.8f
 */
@property (nonatomic) CGFloat minimumScaleOnSwipe;

/*
 Rotate the Y axis when a view controller is swiped
 Default value is NO
 */
@property  (nonatomic, getter = isRotateYAxisWhenSwipe) BOOL rotateYAxisWhenSwipe;

/*
 if scalingWhenSwipe is set to YES then you can set the mximum inclinaison angle
 Default value is 10
 */
@property (nonatomic) CGFloat maximumInclinaisonAngle;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (id)initWithViewControllers:(NSArray *)viewControllers;

/**
 Pushes a view controller onto the receiver’s stack and updates the display.
 Remove every view controllers between the current one and the newly pushed one.
 @param viewController the view controller to be pushed.
 @param animated set YES if you want an transition animation.
 */
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated;
/**
 Pushes a view controller onto the receiver’s stack and updates the display.
 @param viewController the view controller to be pushed.
 @param animated set YES if you want an transition animation.
 @param removeInBetweenVC Is you are in a stackType DMGesturedNavigationControllerStackNavigationFree it is 
 possible that the visible view controller is not the last one the stack.
 Set YES if you want to remove every view controllers between the new one you wan to push and the visible one
 Set NO if you don't want to remove in between VC, the passed view controller will be added at the end and displayed.
 If your stack type is set to DMGesturedNavigationControllerStackLikeNavigationController this parameter will have no 
 effect
 */
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
removeInBetweenViewControllers:(BOOL)removeInBetweenVC;

/**
 Insert the passed view controller at the specified offset, preserve the stack in between, after and before.
 */
- (void)inserViewController:(UIViewController *)viewController
              atStackOffset:(NSInteger)offset
                   animated:(BOOL)animated;
/**
 Remove the passed view controller (if present) from the stack, navigate to the previous view controller
 You cannot remove the root view controller
 */
- (void)removeViewController:(UIViewController *)viewControlller
                    animated:(BOOL)animated;

/**
 Pops the top view controller from the navigation stack and updates the display.
 @param animated 
 Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller 
 before its view is displayed.
 If your stackType is in DMGesturedNavigationControllerStackLikeNavigationController the previous view controller
 will be removed from the stack.
 If your top view controller is the root of the stack this method does nothing
 */

- (void)popViewControllerAnimated:(BOOL)animated;
/**
 Pops all the view controllers on the stack except the root view controller and updates the display.
 View controller will be removed from the stack only if the stack type is set to 
 DMGesturedNavigationControllerStackLikeNavigationController
 @param Animated pass yes if you want the transition to be animated
 */
- (void)popToRootViewControllerAnimated:(BOOL)animated;
/*
 Navigate to the specified view controller
 @param viewController Can't be nil, will trigger an assert error if not in the stack or nil
 @param animated Specify YES if you want the transition to the new ViewController animated.
 */
- (void)navigateToViewController:(UIViewController *)viewController animated:(BOOL)animated;
/**
 @param hidden
 Specify YES to hide the navigation bar or NO to show it.
 @param animated
 Specify YES if you want to animate the change in visibility or 
 NO if you want the navigation bar to appear immediately.
 */
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;
/**
 @param viewController
 Pass the view controller which you want to know if it is a child view controller or not.
 @return YES if present in the stack, NO if not present.
 */
- (BOOL)containViewController:(UIViewController *)viewController;

/**
 @return the standard UINavigationBar height regarding the iOS version. 
 If iOS 6 the returned height is 44.0f, if iOS 7+, the returned value is 64.0f
 */
+ (CGFloat)standardNavBarHeight;
@end

/**
 Category that can be used if you are in a child view controller UIViewController subclass of
 DMGesturedNavigationController.
 Provide various useful properties
 */
@interface UIViewController (UIViewControllerGesturedNavigationController)
@property (nonatomic, readonly, weak) DMGesturedNavigationController *gesturedNavigationController;
@property (nonatomic, readonly, weak) UIViewController *previousViewController;
@property (nonatomic, readonly, weak) UIViewController *nextViewController;
@property (nonatomic, readonly) NSInteger gesturedNavigationControllerOffset;
@property (nonatomic, readonly, getter = isVisible) BOOL visible;
@property (nonatomic, readonly, getter = isActive) BOOL active;
- (void)pushViewControllerToSelf;
@end
